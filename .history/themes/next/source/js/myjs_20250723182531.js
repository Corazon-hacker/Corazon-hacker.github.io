document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('categoryContainer');
  if (!container) return;
  
  // 1. 添加折叠图标
  container.querySelectorAll('.category-list-item').forEach(item => {
    const childList = item.querySelector('ul');
    if (childList) {
      const header = item.querySelector('.category-list-link').parentNode;
      
      // 创建折叠图标
      const icon = document.createElement('i');
      icon.className = 'fa fa-caret-right category-toggle-icon';
      header.insertBefore(icon, header.firstChild);
      
      // 添加点击事件处理
      header.addEventListener('click', function(e) {
        if (e.target.tagName === 'A') {
          e.preventDefault();
        }
        
        const isExpanded = childList.style.display !== 'none';
        childList.style.display = isExpanded ? 'none' : 'block';
        icon.classList.toggle('fa-caret-right', !isExpanded);
        icon.classList.toggle('fa-caret-down', isExpanded);
      });
    }
  });
  
  // 2. 初始隐藏所有子分类
  container.querySelectorAll('.category-list-item ul').forEach(ul => {
    ul.style.display = 'none';
  });
});