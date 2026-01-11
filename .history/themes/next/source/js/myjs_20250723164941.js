document.addEventListener('DOMContentLoaded', function() {
  console.log('DOM loaded, initializing category folding...');
  
  document.querySelectorAll('.category-header').forEach(header => {
    console.log('Found category header:', header);
    
    const toggleIcon = header.querySelector('.category-toggle-icon');
    const childContainer = header.nextElementSibling;
    
    if (toggleIcon && childContainer && childContainer.classList.contains('category-list-child')) {
      console.log('Initializing collapsible for:', header.textContent);
      
      // 初始隐藏子分类
      childContainer.style.display = 'none';
      
      header.addEventListener('click', function(e) {
        // 阻止默认行为（包括链接跳转）
        e.preventDefault();
        e.stopPropagation();
        
        const isExpanded = childContainer.style.display === 'block';
        childContainer.style.display = isExpanded ? 'none' : 'block';
        
        toggleIcon.classList.toggle('fa-caret-right', isExpanded);
        toggleIcon.classList.toggle('fa-caret-down', !isExpanded);
      });
    }
  });
});