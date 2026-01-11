document.addEventListener('DOMContentLoaded', function() {
  // 添加层级标识和折叠图标
  document.querySelectorAll('.category-list li').forEach(item => {
    const childList = item.querySelector('.category-list-child');
    
    if (childList) {
      // 标记有子分类的项
      item.classList.add('has-children');
      
      // 添加点击事件
      const link = item.querySelector('a');
      link.addEventListener('click', function(e) {
        // 阻止默认跳转行为
        e.preventDefault();
        
        // 切换展开状态
        item.classList.toggle('expanded');
      });
    }
  });
  
  // 可选：默认展开所有分类
  // document.querySelectorAll('.category-list .has-children').forEach(item => {
  //   item.classList.add('expanded');
  // });
});