document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('categoryContainer');
  if (!container) return;
  
  // 添加折叠图标和事件
  container.querySelectorAll('.category-list-item').forEach(item => {
    const link = item.querySelector('.category-list-link');
    const childList = item.querySelector('ul');
    
    if (childList) {
      // 添加折叠图标
      const icon = document.createElement('i');
      icon.className = 'fa fa-caret-right category-toggle-icon';
      link.parentNode.insertBefore(icon, link);
      
      // 初始隐藏子分类
      childList.style.display = 'none';
      
      // 添加点击事件处理
      link.parentNode.addEventListener('click', function(e) {
        if (e.target.tagName === 'A') {
          e.preventDefault();
        }
        
        const isExpanded = childList.style.display === 'block';
        childList.style.display = isExpanded ? 'none' : 'block';
        icon.classList.toggle('fa-caret-right', isExpanded);
        icon.classList.toggle('fa-caret-down', !isExpanded);
      });
    } else {
      // 没有子分类的是最后一级
      link.addEventListener('click', function(e) {
        e.preventDefault();
        
        // 获取分类名称和路径
        const categoryName = link.textContent.trim();
        const categoryPath = link.getAttribute('href');
        
        // 显示文章列表
        loadCategoryPosts(categoryName, categoryPath);
      });
    }
  });
  
  // 加载分类文章的函数
  function loadCategoryPosts(categoryName, categoryPath) {
    // 显示当前分类名称
    document.getElementById('currentCategoryName').textContent = categoryName;
    
    // 显示文章容器
    const postsContainer = document.getElementById('categoryPostsContainer');
    postsContainer.style.display = 'block';
    
    // 获取文章列表容器
    const postsList = document.getElementById('categoryPostsList');
    postsList.innerHTML = '<p>加载中...</p>';
    
    // 发送AJAX请求获取分类文章
    fetch(categoryPath)
      .then(response => response.text())
      .then(html => {
        // 解析HTML获取文章列表
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        const posts = doc.querySelectorAll('.post');
        
        // 清空容器
        postsList.innerHTML = '';
        
        // 添加文章到列表
        if (posts.length > 0) {
          posts.forEach(post => {
            const clone = post.cloneNode(true);
            postsList.appendChild(clone);
          });
        } else {
          postsList.innerHTML = '<p>该分类下暂无文章</p>';
        }
        
        // 滚动到文章区域
        postsContainer.scrollIntoView({ behavior: 'smooth' });
      })
      .catch(error => {
        console.error('加载文章失败:', error);
        postsList.innerHTML = '<p>加载文章失败，请稍后再试</p>';
      });
  }
});