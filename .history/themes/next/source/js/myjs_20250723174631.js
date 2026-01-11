document.addEventListener('DOMContentLoaded', function() {
  // 为有子分类的项添加折叠功能
  document.querySelectorAll('.category-header').forEach(header => {
    const categoryName = header.getAttribute('data-category');
    const hasChildren = categoryName.includes('/');
    
    if (hasChildren) {
      header.style.cursor = 'pointer';
      const toggleIcon = header.querySelector('.category-toggle-icon');
      
      header.addEventListener('click', function(e) {
        e.preventDefault();
        
        // 简单实现 - 切换图标
        if (toggleIcon.classList.contains('fa-caret-right')) {
          toggleIcon.classList.remove('fa-caret-right');
          toggleIcon.classList.add('fa-caret-down');
          // 这里可以添加显示子分类的逻辑
        } else {
          toggleIcon.classList.remove('fa-caret-down');
          toggleIcon.classList.add('fa-caret-right');
          // 这里可以添加隐藏子分类的逻辑
        }
      });
    }
  });
});