document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('categoryContainer');
  if (!container) return;
  
  // 添加折叠功能
  container.querySelectorAll('.category-header').forEach(header => {
    const icon = header.querySelector('.category-toggle-icon');
    const childList = header.nextElementSibling;
    
    // 只有有子分类的项才添加折叠功能
    if (icon && childList && childList.classList.contains('category-list-child')) {
      // 初始隐藏子分类
      childList.style.display = 'none';
      
      // 添加点击事件
      header.addEventListener('click', function(e) {
        // 阻止事件冒泡，防止触发父分类的事件
        e.stopPropagation();
        
        // 切换展开状态
        const isExpanded = childList.style.display === 'block';
        
        if (isExpanded) {
          childList.style.display = 'none';
          icon.classList.remove('fa-caret-down');
          icon.classList.add('fa-caret-right');
        } else {
          childList.style.display = 'block';
          icon.classList.remove('fa-caret-right');
          icon.classList.add('fa-caret-down');
        }
      });
    }
  });
  
  // 为最末级分类添加文章显示功能
  container.querySelectorAll('.category-list-list-item:not(:has(.category-list-child)) .category-header').forEach(header => {
    const link = header.querySelector('a.category-list-list-link');
    const count = header.querySelector('.category-list-list-count');
    
    if (link) {
      // 添加点击事件显示文章
      header.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        // 获取分类名称
        const categoryName = link.textContent.trim();
        
        // 移除之前可能存在的文章列表
        const existingArticles = header.nextElementSibling;
        if (existingArticles && existingArticles.classList.contains('category-articles')) {
          existingArticles.remove();
          count.textContent = count.getAttribute('data-original-count');
          return;
        }
        
        // 显示加载状态
        const originalText = count.textContent;
        count.textContent = '加载中...';
        
        // 异步获取文章列表
        fetchCategoryArticles(categoryName)
          .then(articles => {
            // 恢复原始计数
            count.textContent = originalText;
            
            // 创建文章列表容器
            const articlesContainer = document.createElement('div');
            articlesContainer.className = 'category-articles';
            
            // 创建文章列表
            const ul = document.createElement('ul');
            ul.className = 'article-list';
            
            articles.forEach(article => {
              const li = document.createElement('li');
              const a = document.createElement('a');
              a.href = article.path;
              a.textContent = article.title;
              li.appendChild(a);
              ul.appendChild(li);
            });
            
            articlesContainer.appendChild(ul);
            
            // 在分类项后插入文章列表
            header.parentNode.insertBefore(articlesContainer, header.nextElementSibling);
          })
          .catch(error => {
            console.error('获取文章列表失败:', error);
            count.textContent = originalText;
          });
      });
    }
  });
  
  // 模拟获取分类文章的函数
  function fetchCategoryArticles(categoryName) {
    return new Promise((resolve) => {
      // 这里应该是实际的 API 调用
      // 模拟延迟
      setTimeout(() => {
        resolve([
          { title: `${categoryName}下的文章1`, path: '/path/to/article1' },
          { title: `${categoryName}下的文章2`, path: '/path/to/article2' },
          { title: `${categoryName}下的文章3`, path: '/path/to/article3' }
        ]);
      }, 500);
    });
  }
});