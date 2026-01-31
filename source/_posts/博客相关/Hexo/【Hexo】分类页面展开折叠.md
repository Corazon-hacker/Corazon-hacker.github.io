---
title: 【Hexo】分类页面展开折叠
categories:
  - 博客相关
  - Hexo
comments: true
abbrlink: 15e23f74
date: 2025-07-23 11:21:18
description:
tags:
top:
---

- 原来的分类页面太丑了，并且分类之间看的不是很清楚。于是我就想优化一下，添加新的样式。
- 添加好了以后，我又觉得如果后期文章增多，页面就会非常杂乱，因此我又优化成了可以展开折叠的页面。
- 优化成可以展开折叠的页面之后，看到最后一层分类的时候总感觉空荡荡的，总觉得到这样了，不如把所有的文章都直接显示出来得了。

于是便有了这篇文章。

## 分类折叠功能

在themes\next\layout\page.swig中，找到分类页面，替换成下面的代码：

```html
        {% elif page.type === 'categories' %}
        <div class="category-all-page">
          <div class="category-all-title">
            {{ _p('counter.categories', site.categories.length) }}
          </div>
          <div class="category-all" id="categoryContainer">
            {{ list_categories() }}
          </div>
```

我的自定义CSS样式在source\_data\styles.styl中，在你的自定义样式中添加：

```css
/* 分类折叠样式 */
.category-toggle-icon {
  display: inline-block;
  width: 16px;
  margin-right: 5px;
  text-align: center;
  cursor: pointer;
}

.category-list-child {
  padding-left: 20px;
}

.category-list-link {
  position: relative;
  padding-left: 0 !important;
}

/* 添加手型光标表示可点击 */
.category-list-item > .category-list-link {
  cursor: pointer;
}

/* 悬停效果 */
.category-list-item > .category-list-link:hover {
  background-color: #f5f5f5;
}
```

创建js文件themes\next\source\js\category-collapse.js：

```javascript
document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('categoryContainer');
  if (!container) return;
  
  // 1. 添加折叠图标
  container.querySelectorAll('.category-list-item').forEach(item => {
    const childList = item.querySelector('ul');
    if (childList) {
      const header = item.querySelector('.category-list-link').parentNode;
      
      // 创建折叠图标
      const icon = document.createElement('i');
      icon.className = 'fa fa-caret-right category-toggle-icon';
      header.insertBefore(icon, header.firstChild);
      
      // 添加点击事件处理
      header.addEventListener('click', function(e) {
        if (e.target.tagName === 'A') {
          e.preventDefault();
        }
        
        const isExpanded = childList.style.display !== 'none';
        childList.style.display = isExpanded ? 'none' : 'block';
        icon.classList.toggle('fa-caret-right', !isExpanded);
        icon.classList.toggle('fa-caret-down', isExpanded);
      });
    }
  });
  
  // 2. 初始隐藏所有子分类
  container.querySelectorAll('.category-list-item ul').forEach(ul => {
    ul.style.display = 'none';
  });
});
```

记得在themes\next\layout\_layout.swig中的`<body>`前引用：

```html
  {{ partial('_scripts/noscript.swig', {}, {cache: theme.cache.enable}) }}
  {% if page.type === 'categories' %}
  <script src="/js/category-collapse.js"></script>
  {% endif %} 
```

没错就这么简单。剩下的可以优化一下CSS。

## 文章折叠展开

终于做好了，肝死我了：



### themes\next\layout\page.swig

```html
          {% elif page.type === 'categories' %}
<--
          <div class="category-all-page">
            <div class="category-all-title">
              {{ _p('counter.categories', site.categories.length) }}
            </div>
            <div class="category-all">
              {{ list_categories() }}
            </div>
          </div>
-->
          <div class="category-all-page">
            <div class="category-all-title">
              {{ _p('counter.categories', site.categories.length) }}
            </div>
            
            <div class="category-container">
              <!-- 左侧分类树 -->
              <div class="category-tree">
                <div class="category-all" id="categoryContainer">
                  {{ list_categories() }}
                </div>
              </div>
              
              <!-- 右侧文章列表 -->
              <div id="categoryPostsContainer" class="category-posts-container">
                <div class="posts-collapse">
                  <div class="collection-title">
                    <h2 class="collection-header">
                      <span id="currentCategoryName"></span>
                      <small>{{ __('title.category') }}</small>
                    </h2>
                  </div>
                  <div id="categoryPostsList"></div>
                </div>
              </div>
            </div>
          </div>
```



### themes\next\source\js\category-collapse.js

```javascript
document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('categoryContainer');
  if (!container) return;
  
  // 遍历所有分类项
  container.querySelectorAll('.category-list-item').forEach(item => {
    const link = item.querySelector('.category-list-link');
    const childList = item.querySelector('ul');
    const count = item.querySelector('.category-list-count');
    
    // 移除所有折叠图标（如果有）
    const existingIcons = item.querySelectorAll('.category-toggle-icon');
    existingIcons.forEach(icon => icon.remove());
    
    // 如果有子分类，添加折叠图标到右侧
    if (childList) {
      const icon = document.createElement('i');
      icon.className = 'fa fa-caret-down category-toggle-icon';
      icon.style.marginLeft = '5px';
      icon.style.cursor = 'pointer';
      
      // 添加到计数后面
      if (count) {
        count.parentNode.insertBefore(icon, count.nextSibling);
      } else {
        link.parentNode.insertBefore(icon, link.nextSibling);
      }
      
      // 初始状态：第一级分类展开，其他级折叠
      const isTopLevel = item.parentElement.classList.contains('category-list');
      if (!isTopLevel) {
        childList.style.display = 'none';
        icon.classList.remove('fa-caret-down');
        icon.classList.add('fa-caret-right');
      }
      
      // 添加折叠/展开事件
      icon.addEventListener('click', function(e) {
        e.stopPropagation();
        const isExpanded = childList.style.display === 'block' || childList.style.display === '';
        childList.style.display = isExpanded ? 'none' : 'block';
        icon.classList.toggle('fa-caret-down', !isExpanded);
        icon.classList.toggle('fa-caret-right', isExpanded);
      });
    }
    
    // 为分类链接绑定点击事件
    // 在分类链接点击事件中添加展开子分类功能
    link.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      
      // 获取分类名称和路径
      const categoryName = link.textContent.trim();
      const categoryPath = link.getAttribute('href');
      
      // 如果有子分类，则切换展开/折叠状态
      const childList = item.querySelector('ul');
      const icon = item.querySelector('.category-toggle-icon');
      if (childList && icon) {
        // 切换展开/折叠状态
        const isExpanded = childList.style.display === 'block' || 
                         childList.style.display === '';
        
        childList.style.display = isExpanded ? 'none' : 'block';
        icon.classList.toggle('fa-caret-down', !isExpanded);
        icon.classList.toggle('fa-caret-right', isExpanded);
      }
      
      // 显示文章列表
      loadCategoryPosts(categoryName, categoryPath);
    });
  });
  
  // 加载分类文章的函数
  function loadCategoryPosts(categoryName, categoryPath) {
    // 移除所有激活状态
    document.querySelectorAll('.category-list-link').forEach(link => {
      link.classList.remove('active-category');
    });
    document.querySelectorAll('.category-list-item').forEach(item => {
      item.classList.remove('active-ancestor');
    });
  
    // 为当前分类添加激活状态
    const currentLink = document.querySelector(`.category-list-link[href="${categoryPath}"]`);
    if (currentLink) {
      currentLink.classList.add('active-category');
      
      // 为当前分类的所有父级添加 active-ancestor
      let parentItem = currentLink.closest('.category-list-child')?.closest('.category-list-item');
      while (parentItem) {
        parentItem.classList.add('active-ancestor');
        parentItem = parentItem.closest('.category-list-child')?.closest('.category-list-item');
      }
    }

    // 显示当前分类名称
    document.getElementById('currentCategoryName').textContent = categoryName;
    
    // 显示文章容器
    const postsContainer = document.getElementById('categoryPostsContainer');
    postsContainer.style.display = 'block';

    // 滚动到分类容器顶部
    document.querySelector('.category-container').scrollTop = 0;
    
    // 获取文章列表容器
    const postsList = document.getElementById('categoryPostsList');
    postsList.innerHTML = '<div class="loading-spinner"></div><p>加载中...</p>';
    
    // 发送AJAX请求获取分类文章
    fetch(categoryPath)
      .then(response => response.text())
      .then(html => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        
        // 确保选择正确的容器
        const postsContainer = doc.querySelector('.category-posts');
        
        if (postsContainer) {
          postsList.innerHTML = postsContainer.innerHTML;
          
          // 添加必要的类名
          postsList.querySelectorAll('.post').forEach(post => {
            post.classList.add('post-collapse-item');
          });
          
          postsList.querySelectorAll('.post-title-link').forEach(link => {
            link.classList.add('post-title-link');
          });
        } else {
          postsList.innerHTML = '<p>该分类下暂无文章</p>';
        }
      })
      .catch(error => {
        console.error('加载文章失败:', error);
        postsList.innerHTML = '<p>加载文章失败，请稍后再试</p>';
      });
  }
  // 在遍历分类项后添加以下代码
  // 折叠除第一个顶级分类外的所有顶级分类
  const topLevelItems = container.querySelectorAll('.category-list > .category-list-item');
  topLevelItems.forEach((item, index) => {
    if (index > 0) { // 跳过第一个分类
      const childList = item.querySelector('ul');
      const icon = item.querySelector('.category-toggle-icon');
      if (childList && icon) {
        childList.style.display = 'none';
        icon.classList.remove('fa-caret-down');
        icon.classList.add('fa-caret-right');
      }
    }
  });

  // 确保第一个分类的子分类展开
  const firstTopLevelItem = topLevelItems[0];
  if (firstTopLevelItem) {
    const childList = firstTopLevelItem.querySelector('ul');
    const icon = firstTopLevelItem.querySelector('.category-toggle-icon');
    if (childList && icon) {
      childList.style.display = 'block';
      icon.classList.add('fa-caret-down');
      icon.classList.remove('fa-caret-right');
    }
  }
  // 默认加载第一个分类的文章
  const firstCategoryLink = container.querySelector('.category-list-link');
  if (firstCategoryLink) {
    const categoryName = firstCategoryLink.textContent.trim();
    const categoryPath = firstCategoryLink.getAttribute('href');
    loadCategoryPosts(categoryName, categoryPath);
  }
});
```

### themes\next\layout\category.swig

```html
  <div class="post-block">
    <div class="posts-collapse">
      <div class="collection-title">
        <h2 class="collection-header">
          {{- page.category }}
          <small>{{ __('title.category') }}</small>
        </h2>
      </div>
      <div class="category-posts"> <!-- 添加这个类名 -->
      	{{ post_template.render(page.posts) }}
      </div>
  	</div>
  </div>
```

### themes\next\layout\_macro\post-collapse.swig

```html
  <article class="post post-collapse-item" itemscope itemtype="http://schema.org/Article">
    <header class="post-header">
<!--
      <div class="post-meta">
        <time itemprop="dateCreated"
              datetime="{{ moment(post.date).format() }}"
              content="{{ date(post.date, config.date_format) }}">
          {{ date(post.date, 'MM-DD') }}
        </time>
      </div>
-->
      <div class="post-title">
        <span class="post-meta">
          <time itemprop="dateCreated"
                datetime="{{ moment(post.date).format() }}"
                content="{{ date(post.date, config.date_format) }}">
            {{ date(post.date, 'MM-DD') }}
          </time>
        </span>
        {%- if post.link %}{# Link posts #}
          {%- set postTitleIcon = '<i class="fa fa-external-link-alt"></i>' %}
          {%- set postText = post.title or post.link %}
          {{ next_url(post.link, postText + postTitleIcon, {class: 'post-title-link post-title-link-external', itemprop: 'url'}) }}
        {% else %}
          <a class="post-title-link" href="{{ url_for(post.path) }}" itemprop="url">
            <span itemprop="name">{{ post.title or __('post.untitled') }}</span>
          </a>
        {%- endif %}
      </div>

    </header>
  </article>
```

### source\_data\styles.styl

```CSS
/* 分类页面布局 */
/* ===================== 滚动条美化 - 白色样式 ===================== */
/* 滚动条美化 */
@supports (scrollbar-color: auto) {
  .category-tree,
  .category-posts-container {
    scrollbar-color: rgba(255, 255, 255, 0.5) rgba(240, 240, 240, 0.5);
    scrollbar-width: thin;
  }
}

/* ===================== 布局优化 ===================== */
.category-container {
  display: flex;
  margin-top: 30px;
  gap: 30px;
  height: 70vh;
  border-radius: 80px;
  .category-tree {
    flex: 0 0 48%;
    min-width: 0;
    overflow-x: visible;
    max-height: 100%;
    overflow-y: auto; /* 恢复垂直滚动条 */
    overflow-x: hidden;
    padding-right: 10px; 
    display: flex;
    flex-direction: column;
    position: relative; /* 为滚动条定位做准备 */
    direction: rtl;
    /* 添加可滚动区域 */
    /* 左侧分类树滚动区域 */

    &::-webkit-scrollbar {
      width: 6px;
    }
    &::-webkit-scrollbar-thumb {
      background: rgba(255, 255, 255, 0.8);
      border: 1px solid rgba(200, 200, 200, 0.5);
    }

  }

/* 确保分类树内容正常显示 */
#categoryContainer {
  direction: ltr; /* 内容从左到右 */
  padding-right: 10px; /* 补偿滚动条宽度 */
}

  .category-posts-container {
    flex: 2;
    display: none;
    overflow-y: auto;
    max-height: 100%;
    background: rgba(255, 255, 255, 0.8); /* 添加半透明白色背景 */
    border-radius: 8px; /* 添加圆角 */
    padding: 10px; /* 增加内边距 */
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); /* 添加阴影增强层次感 */
  }
}

/* 调整分类列表 */
#categoryContainer {
  display: block;
  //padding: 10px 0;
  .category-list {
    display: block;
    max-height: none;
    margin-right: 8px;
  }
}

/* 分类项样式优化 */
.category-list-item {
  overflow: visible; /* 确保内容可见 */
  display: flex;
  min-width: 0; /* 允许内容收缩 */
  flex-wrap: wrap;
  align-items: center;
  margin-bottom: 6px;
  margin: 5px 0px;
  position: relative;
  width: 100%;
  background: rgba(255, 255, 255, 0.2); /* 默认透明背景 */
  border-radius: 6px;
  padding: 5px 8px;
  transition: all 0.3s ease;
  
  /* 确保子分类不会导致溢出 */
  .category-list-child {
    width: 90%;
  }
  
  .category-list-link {
    flex-grow: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    padding: 2px 9px;
    border-radius: 4px;
    color: #2c3e50;
    text-decoration: none !important;
    transition: all 0.3s;
    
    &:hover {
      background-color: #cccccc;
      color: #2841a4f7;
      
    }
  }
  
  .category-list-count {
    flex-shrink: 0;
    background: #eaeef5;
    color: #6c757d;
    font-size: 0.6rem !important; /* 进一步缩小字体大小 */
    padding: 2px 2px; /* 减小内边距 */
    border-radius: 20px;
    transition: all 0.3s;
    min-width: 20px; /* 设置最小宽度 */
    text-align: center; /* 居中显示 */
  }
  
  /* 折叠图标样式 */
  .category-toggle-icon {
    flex-shrink: 0;
    color: #6c757d;
    font-size: 0.9rem;
    margin-left: 5px;
    transition: transform 0.3s ease;
    min-width: 30px;
  }
  
  &:hover .category-list-count {
    background: #d1e0ff;
    color: #4b6cb7;
  }
}

/* 为不同层级添加背景色（降低透明度） */
/* 第一级分类 */
#categoryContainer > .category-list > .category-list-item {
  background: rgba(255, 255, 255, 0.85); /* 降低透明度 */
}

/* 第二级分类 */
#categoryContainer > .category-list > .category-list-item > .category-list-child > .category-list-item {
  background: rgba(200, 230, 255, 0.5); /* 降低透明度 */
}

/* 第三级分类 */
#categoryContainer > .category-list > .category-list-item > .category-list-child > .category-list-item > .category-list-child > .category-list-item {
  background: rgba(230, 255, 230, 0.5); /* 降低透明度 */
}

/* 第四级分类 */
#categoryContainer > .category-list > .category-list-item > .category-list-child > .category-list-item > .category-list-child > .category-list-item > .category-list-child > .category-list-item {
  background: rgba(255, 230, 230, 0.5); /* 降低透明度 */
}

/* 悬停效果 - 只改变当前项 */
/* 只悬停当前项 */
.category-list-item:hover {
  background-color: rgba(240, 248, 255, 0.7) !important;
  z-index: 20;
}

/* 添加以下样式到您的 styles.styl 文件中 */

/* 当前选中分类样式 */
.category-list-link.active-category {
  background-color: #4b6cb7 !important;
  color: white !important;
  
  & + .category-list-count {
    background: white !important;
    color: #4b6cb7 !important;
  }
}

/* 祖先分类样式 */
.category-list-item.active-ancestor > .category-list-link {
  background-color: rgba(200, 230, 255, 0.7) !important;
}


/* 响应式设计优化 */
@media (max-width: 768px) {
  .category-container {
    .category-tree,
    .category-posts-container {
      flex: 0 0 100%; /* 移动端占满宽度 */
      min-width: 100%;
      max-height: none;
    }
    
    .category-tree {
      direction: ltr; /* 移动端恢复默认方向 */
      padding-right: 0;
      max-height: 40vh;
    }
  }
}

/* 确保右侧标题可见 */
.collection-header {
  color: #333333 !important;
  text-shadow: none;
  padding: 0;
  
  #currentCategoryName {
    font-weight: bold;
    font-size: 1.5rem;
    color: #222;
  }
  
  small {
    color: #666 !important;
    font-size: 1rem;
  }
}

/* 文章列表视觉优化 */
#categoryPostsList {
  * {
    opacity: 1 !important;
  }
  
  .post-title-link, 
  .post-title-link span {
    color: #111111 !important;
    //font-weight: 600 !important;
    font-size: 1rem !important;
    
    &:hover {
      color: #4b6cb7 !important;
    }
  }

  .post-meta {
    position: absolute;
    left: 0;
    top: 0;
    display: inline-block;
    padding: 2px 10px;
    font-size: 0.9em;
    color: #666;
    font-size: 0.85rem !important;
    border-radius: 4px;
    margin: 3px 0 3px 5px;

    time {
      border: 0;
    }
  }
  
  .post-header {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin: 0px 15px;
    padding: 8px 0;
    border-bottom: 1px solid #f0f0f0;
    background: rgba(255, 255, 255, 0.3);
    border-radius: 4px;
    padding: 8px 12px;
  }
  
  .post-title {
    display: block;
    height: auto;
    min_height: 1em;
    overflow-wrap: break-word;
    overflow: visible;
    flex-grow: 1;
    width: 100%;
    background: #f8f8f8; /* 仅用于调试 */
    line-height: 1.5;
    font-size: 0;
    padding: 15px 0 10px 0;
  }

  
  .collection-year {
    font-size: 1.2rem;
    font-weight: 600;
    color: #444;
    margin: 20px 0 10px;
    padding-bottom: 5px;
    border-bottom: 1px dashed #ddd;
  }
}

/* 加载动画优化 */
.loading-spinner {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 3px solid rgba(75, 108, 183, 0.2);
  border-radius: 50%;
  border-top-color: #4b6cb7;
  animation: spin 1s ease-in-out infinite;
  margin-right: 10px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}


/* 保持分类列表从左往右分布 */
.category-all-page .category-all {
  direction: ltr;
  margin-top: 0px;
}
#categoryPostsContainer {
  .posts-collapse {
    margin-left: 20px !important;
  }
}

```
