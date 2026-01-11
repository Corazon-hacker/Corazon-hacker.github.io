document.addEventListener('DOMContentLoaded', function() {
  // 为每个有子分类的项添加事件
  document.querySelectorAll('.category-header').forEach(header => {
    const toggleIcon = header.querySelector('.category-toggle-icon');
    const childContainer = header.nextElementSibling;
    
    if (toggleIcon && childContainer && childContainer.classList.contains('category-list-child')) {
      // 初始隐藏子分类
      childContainer.style.display = 'none';
      
      // 添加点击事件
      header.addEventListener('click', function(e) {
        // 阻止默认的链接跳转行为
        if (e.target.tagName === 'A') {
          e.preventDefault();
        }
        
        // 切换展开状态
        const isExpanded = childContainer.style.display === 'block';
        
        if (isExpanded) {
          childContainer.style.display = 'none';
          toggleIcon.classList.remove('fa-caret-down');
          toggleIcon.classList.add('fa-caret-right');
        } else {
          childContainer.style.display = 'block';
          toggleIcon.classList.remove('fa-caret-right');
          toggleIcon.classList.add('fa-caret-down');
        }
      });
    }
  });
});