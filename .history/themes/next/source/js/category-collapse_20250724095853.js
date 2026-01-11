document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('categoryContainer');
  if (!container) return;
  
  // 遍历所有分类项
  container.querySelectorAll('.category-list-item').forEach(item => {
    const childList = item.querySelector('ul');
    
    if (childList) {
      // 判断是否为顶级分类
      const isTopLevel = item.parentElement.classList.contains('category-list') && 
                        item.parentElement.parentElement.id === 'categoryContainer';
      
      // 非顶级分类默认折叠
      if (!isTopLevel) {
        childList.style.display = 'none';
        // 更新图标状态
        const icon = item.querySelector('.category-toggle-icon');
        if (icon) {
          icon.classList.remove('fa-caret-down');
          icon.classList.add('fa-caret-right');
        }
      }
    }
  });
  
  // 添加折叠/展开事件
  icon.addEventListener('click', function(e) {
    e.stopPropagation();
    const isExpanded = childList.style.display === 'block' || 
                      childList.style.display === '';
    
    childList.style.display = isExpanded ? 'none' : 'block';
    
    // 更新所有子项的图标状态
    const allIcons = childList.querySelectorAll('.category-toggle-icon');
    allIcons.forEach(childIcon => {
      if (isExpanded) {
        childIcon.classList.remove('fa-caret-down');
        childIcon.classList.add('fa-caret-right');
      }
    });
    
    // 更新当前图标
    icon.classList.toggle('fa-caret-down', !isExpanded);
    icon.classList.toggle('fa-caret-right', isExpanded);
  });
  
  // 加载分类文章的函数
  function loadCategoryPosts(categoryName, categoryPath) {
    // 移除所有激活状态和祖先状态
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
      
      // 为当前分类的所有父级添加active-ancestor
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
  
  // 默认加载第一个分类的文章
  const firstCategoryLink = container.querySelector('.category-list-link');
  if (firstCategoryLink) {
    const categoryName = firstCategoryLink.textContent.trim();
    const categoryPath = firstCategoryLink.getAttribute('href');
    loadCategoryPosts(categoryName, categoryPath);
  }
});