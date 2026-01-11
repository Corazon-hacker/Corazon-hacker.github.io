document.addEventListener('DOMContentLoaded', function() {
  // 移除复杂的折叠逻辑
  console.log('DOM loaded, initializing category folding...');
  
  // 简单实现 - 为所有分类项添加点击事件
  document.querySelectorAll('.category-header').forEach(header => {
    header.addEventListener('click', function(e) {
      e.preventDefault();
      alert('分类功能正在开发中');
    });
  });
});