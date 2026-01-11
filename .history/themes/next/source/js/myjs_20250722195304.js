document.addEventListener('DOMContentLoaded', function() {
    // 为每个有子分类的项添加事件
    document.querySelectorAll('.category-header').forEach(header => {
      const hasChildren = header.nextElementSibling && 
        header.nextElementSibling.classList.contains('category-list-child');
      
      if (hasChildren) {
        // 添加折叠图标
        const icon = header.querySelector('.toggle-icon i');
        if (icon) {
          icon.classList.add('fa-caret-right');
        }
        
        // 添加点击事件
        header.addEventListener('click', function(e) {
          // 阻止默认的链接跳转行为
          if (e.target.tagName === 'A') {
            e.preventDefault();
          }
          
          const childContainer = this.nextElementSibling;
          if (childContainer && childContainer.classList.contains('category-list-child')) {
            childContainer.classList.toggle('expanded');
            const icon = this.querySelector('.toggle-icon i');
            if (icon) {
              icon.classList.toggle('fa-caret-right');
              icon.classList.toggle('fa-caret-down');
            }
          }
        });
      }
    });
  });