
document.addEventListener("DOMContentLoaded", function () {
    // 获取所有的分类项
    const categoryItems = document.querySelectorAll('.category-list-item > .category-list-link');
  
    categoryItems.forEach(item => {
      item.addEventListener('click', function (event) {
        event.preventDefault(); // 防止默认的链接跳转行为
        const parentLi = this.parentElement; // 获取父级 <li> 元素
        const childUl = parentLi.querySelector('.category-list-child'); // 获取子 <ul>
  
        if (childUl) {
          parentLi.classList.toggle('active'); // 切换 active 类
        }
      });
    });
  });

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
  