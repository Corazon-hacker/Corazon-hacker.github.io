{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}
  {%- set page_title_suffix = ' | ' + title %}

  {%- if page.type === 'categories' and not page.title %}
    {{- __('title.category') + page_title_suffix }}
  {%- elif page.type === 'tags' and not page.title %}
    {{- __('title.tag') + page_title_suffix }}
  {%- elif page.type === 'schedule' and not page.title %}
    {{- __('title.schedule') + page_title_suffix }}
  {%- else %}
    {{- page.title + page_title_suffix }}
  {%- endif %}
{% endblock %}

{% block class %}page posts-expand{% endblock %}

{% block content %}

    {##################}
    {### PAGE BLOCK ###}
    {##################}
    <div class="post-block" lang="{{ page.lang or config.language }}">
      {% include '_partials/page/page-header.swig' %}
      {#################}
      {### PAGE BODY ###}
      {#################}

      <div class="post-body{%- if page.direction and page.direction.toLowerCase() === 'rtl' %} rtl{%- endif %}">
        {%- if page.type === 'tags' %}
          <div class="tag-cloud">
              <div class="tag-cloud-title" style="color: #000000">
              {{ _p('counter.tag_cloud', site.tags.length) }}
              </div>
              <div class="tag-cloud-tags">
              {{ tagcloud({
                  min_font   : theme.tagcloud.min,
                  max_font   : theme.tagcloud.max,
                  amount     : theme.tagcloud.amount,
                  color      : true,
                  start_color: theme.tagcloud.start,
                  end_color  : theme.tagcloud.end})
              }}
              </div>
          </div>
          {# 自定义爱心标签云 #}
          {#{% include 'tags-style/tag-love.swig' %}#}
          {# 自定义大标签 #}
          {#{% include 'tags-style/tagcanvas.swig' %}#}
          {# 自定义彩色简约标签主题 #}
          {#{% include 'tags-style/tag-simple.swig' %}#}
          {# 球状标签云 #}
          {% include 'tags-style/tag-bubble.swig' %}
          {# 老分类注释掉 #}
{% elif page.type === 'categories' %}
{% if page.type === 'categories' %}
<div class="category-all-page">
  <div class="category-all-title">
    {{ _p('counter.categories', site.categories.length) }}
  </div>
  
  {# 一级分类（没有斜杠的） #}
  <div class="level-1-categories">
    <h3>一级分类</h3>
    <ul>
      {% for category in site.categories.toArray() %}
        {% if not category.name.includes('/') %}
          <li>
            {{ category.name }} - {{ category.length }}篇文章
            <ul>
              {% for post in category.posts %}
                <li>{{ post.title }}</li>
              {% endfor %}
            </ul>
          </li>
        {% endif %}
      {% endfor %}
    </ul>
  </div>
  
  {# 多级分类（有斜杠的） #}
  <div class="multi-level-categories">
    <h3>多级分类</h3>
    <ul>
      {% for category in site.categories.toArray() %}
        {% if category.name.includes('/') %}
          <li>
            {{ category.name }} - {{ category.length }}篇文章
            <ul>
              {% for post in category.posts %}
                <li>{{ post.title }}</li>
              {% endfor %}
            </ul>
          </li>
        {% endif %}
      {% endfor %}
    </ul>
  </div>
  
  {# 分类层级统计 #}
  <div class="category-stats">
    <h3>分类层级统计</h3>
    <table>
      <thead>
        <tr>
          <th>分类名称</th>
          <th>层级深度</th>
          <th>文章数量</th>
          <th>路径</th>
        </tr>
      </thead>
      <tbody>
        {% for category in site.categories.toArray() %}
          <tr>
            <td>{{ category.name }}</td>
            <td>{{ category.name.split('/').length }}级</td>
            <td>{{ category.length }}</td>
            <td>{{ category.path }}</td>
          </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
</div>
{% endif %}
<div class="category-all-page">
  <div class="category-all-title">
    {{ _p('counter.categories', site.categories.length) }}
  </div>
  <div class="category-all" id="categoryContainer">
    <ul class="category-list-list">
      {% for category in site.categories.toArray() %}
        <li class="category-list-list-item">
          <div class="category-header" data-category="{{ category.name | safe }}">
            <a class="category-list-list-link" href="{{ url_for(category.path) }}">
              {{ category.name }}
            </a>
            <span class="category-list-list-count">{{ category.length }}</span>
          </div>
        </li>
      {% endfor %}
    </ul>
  </div>
</div>

<script>
  // 简单的客户端分组实现
  document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('categoryContainer');
    if (!container) return;
    
    // 获取所有分类项
    const items = Array.from(container.querySelectorAll('.category-list-list-item'));
    
    // 按斜杠分组
    const grouped = {};
    items.forEach(item => {
      const name = item.querySelector('.category-header').dataset.category;
      const parts = name.split('/');
      
      let currentLevel = grouped;
      parts.forEach((part, index) => {
        if (!currentLevel[part]) {
          currentLevel[part] = {
            element: index === parts.length - 1 ? item : null,
            children: {}
          };
        }
        currentLevel = currentLevel[part].children;
      });
    });
    
    // 清空容器
    container.innerHTML = '';
    
    // 递归渲染树结构
    function renderTree(data, level = 0) {
      const ul = document.createElement('ul');
      ul.className = level === 0 ? 'category-list-list' : 'category-list-child';
      
      Object.entries(data).forEach(([name, node]) => {
        const li = document.createElement('li');
        li.className = 'category-list-list-item';
        
        if (node.element) {
          // 叶子节点
          li.appendChild(node.element.querySelector('.category-header').cloneNode(true));
        } else {
          // 分组节点
          const header = document.createElement('div');
          header.className = 'category-header';
          header.innerHTML = `
            <i class="fa fa-caret-right category-toggle-icon"></i>
            <span class="category-list-list-link">${name}</span>
            <span class="category-list-list-count">${Object.keys(node.children).length}</span>
          `;
          li.appendChild(header);
          
          if (Object.keys(node.children).length > 0) {
            li.appendChild(renderTree(node.children, level + 1));
          }
        }
        
        ul.appendChild(li);
      });
      
      return ul;
    }
    
    container.appendChild(renderTree(grouped));
    
    // 添加折叠功能
    container.querySelectorAll('.category-header').forEach(header => {
      const icon = header.querySelector('.category-toggle-icon');
      const childList = header.nextElementSibling;
      
      if (icon && childList && childList.classList.contains('category-list-child')) {
        childList.style.display = 'none';
        
        header.addEventListener('click', function() {
          const isExpanded = childList.style.display === 'block';
          childList.style.display = isExpanded ? 'none' : 'block';
          icon.classList.toggle('fa-caret-right', isExpanded);
          icon.classList.toggle('fa-caret-down', !isExpanded);
        });
      }
    });
  });
</script>
        {% elif page.type === 'schedule' %}
          <div class="event-list">
          </div>
          {% include '_scripts/pages/schedule.swig' %}
        {% else %}
          {{ page.content }}
        {%- endif %}
      </div>
      {#####################}
      {### END PAGE BODY ###}
      {#####################}
    </div>
    {% include '_partials/page/breadcrumb.swig' %}
    {######################}
    {### END PAGE BLOCK ###}
    {######################}

{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(true) }}
{% endblock %}
