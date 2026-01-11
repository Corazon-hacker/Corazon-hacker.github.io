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
    link.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      
      // 获取分类名称和路径
      const categoryName = link.textContent.trim();
      const categoryPath = link.getAttribute('href');
      
      // 显示文章列表
      loadCategoryPosts(categoryName, categoryPath);
    });
  });
  
  // 加载分类文章的函数
  function loadCategoryPosts(categoryName, categoryPath) {
    // 移除所有分类的激活状态
    document.querySelectorAll('.category-list-link').forEach(link => {
      link.classList.remove('active-category');
    });

    // 为当前分类添加激活状态
    const currentLink = document.querySelector(`.category-list-link[href="${categoryPath}"]`);
    if (currentLink) {
      currentLink.classList.add('active-category');
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
  
  // 默认加载第一个分类的文章
  const firstCategoryLink = container.querySelector('.category-list-link');
  if (firstCategoryLink) {
    const categoryName = firstCategoryLink.textContent.trim();
    const categoryPath = firstCategoryLink.getAttribute('href');
    loadCategoryPosts(categoryName, categoryPath);
  }
});