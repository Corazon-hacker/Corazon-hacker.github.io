// 简单版折叠功能
document.addEventListener('DOMContentLoaded', function() {
  // 隐藏所有子分类
  document.querySelectorAll('.category-list-child').forEach(child => {
    child.style.display = 'none';
  });
  
  // 添加点击事件
  document.querySelectorAll('.category-list li').forEach(item => {
    const link = item.querySelector('a');
    const childList = item.querySelector('.category-list-child');
    
    if (childList) {
      // 添加折叠图标
      const icon = document.createElement('i');
      icon.className = 'fa fa-caret-right';
      icon.style.marginRight = '8px';
      link.insertBefore(icon, link.firstChild);
      
      link.addEventListener('click', function(e) {
        e.preventDefault();
        
        if (childList.style.display === 'none') {
          childList.style.display = 'block';
          icon.className = 'fa fa-caret-down';
        } else {
          childList.style.display = 'none';
          icon.className = 'fa fa-caret-right';
        }
      });
    }
  });
});