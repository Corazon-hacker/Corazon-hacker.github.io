  document.addEventListener("DOMContentLoaded", function () {
    const categoryItems = document.querySelectorAll('.category-list-item > .category-list-link');
  
    categoryItems.forEach(item => {
      item.addEventListener('click', function (event) {
        const parentLi = this.parentElement;
        const childUl = parentLi.querySelector('.category-list-child');
  
        if (childUl) {
          event.preventDefault(); // 阻止默认链接跳转行为
          parentLi.classList.toggle('active'); // 切换 active 类
        }
      });
    });
  });
  