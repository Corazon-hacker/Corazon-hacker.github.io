document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('categoryContainer');
  if (!container) return;
  
  // 添加折叠图标和事件
  container.querySelectorAll('.category-list-item').forEach(item => {
    const link = item.querySelector('.category-list-link');
    const childList = item.querySelector('ul');
    
    // 判断是否为第一层分类（直接子元素）
    const isTopLevel = item.parentElement.classList.contains('category-list');
    
    if (childList) {
      // 如果不是第一层分类，添加折叠图标
      if (!isTopLevel) {
        const icon = document.createElement('i');
        icon.className = 'fa fa-caret-right category-toggle-icon';
        item.insertBefore(icon, link);
      }
      
      // 初始隐藏子分类（第一层默认展开）
      if (!isTopLevel) {
        childList.style.display = 'none';
      }
      
      // 添加点击事件处理
      const toggleHandler = function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        const isExpanded = childList.style.display === 'block';
        childList.style.display = isExpanded ? 'none' : 'block';
        
        // 更新图标状态（仅当存在图标时）
        if (!isTopLevel) {
          const icon = item.querySelector('.category-toggle-icon');
          icon.classList.toggle('fa-caret-right', isExpanded);
          icon.classList.toggle('fa-caret-down', !isExpanded);
        }
      };
      
      // 添加事件监听
      if (!isTopLevel) {
        const icon = item.querySelector('.category-toggle-icon');
        icon.addEventListener('click', toggleHandler);
      }
      link.addEventListener('click', toggleHandler);
    } else {
      // 没有子分类的是最后一级
// 修改最后一级分类的点击事件
    link.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();

      // 获取分类名称和路径
      const categoryName = link.textContent.trim();
      const categoryPath = link.getAttribute('href');

      // 显示文章列表
      loadCategoryPosts(categoryName, categoryPath, link); // 添加第三个参数
    });

    // 加载分类文章的函数
    function loadCategoryPosts(categoryName, categoryPath, clickedLink) {
      // 移除所有分类的激活状态
      document.querySelectorAll('.category-list-link').forEach(link => {
        link.classList.remove('active-category');
      });

      // 为当前分类添加激活状态
      clickedLink.classList.add('active-category'); // 使用传入的 clickedLink
  
      
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
});