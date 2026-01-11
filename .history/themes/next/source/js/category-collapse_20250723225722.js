document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('categoryContainer');
  if (!container) return;
  
  // 遍历所有分类项
  container.querySelectorAll('.category-list-item').forEach(item => {
    const link = item.querySelector('.category-list-link');
    const childList = item.querySelector('ul');
    
    // 移除所有折叠图标
    const existingIcons = item.querySelectorAll('.category-toggle-icon');
    existingIcons.forEach(icon => icon.remove());
    
    // 显示所有子分类（不需要隐藏）
    if (childList) {
      childList.style.display = 'block';
    }
    
    // 为每个分类项绑定点击事件
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