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
<div class="category-all-page">
  <div class="category-all-title">
    {{ _p('counter.categories', site.categories.length) }}
  </div>
  <div class="category-all" id="categoryContainer">
    {# 安全的树构建方法 #}
    {% set root = [] %}
    
    {% for cat in site.categories.toArray() %}
      {% if cat.name and cat.name.length > 0 %}
        {% set parts = cat.name.split('/') %}
        {% set currentLevel = root %}
        
        {% for part in parts %}
          {% if part and part.length > 0 %}
            {% set foundNode = false %}
            
            {# 在当前层级查找节点 #}
            {% for node in currentLevel %}
              {% if node.name === part %}
                {% set node.length = node.length + cat.length %}
                {% set currentLevel = node.children %}
                {% set foundNode = true %}
                {% break %}
              {% endif %}
            {% endfor %}
            
            {# 如果没找到，创建新节点 #}
            {% if not foundNode %}
              {% set newNode = {
                name: part,
                path: cat.path,
                fullName: cat.name,
                length: cat.length,
                children: []
              } %}
              
              {% set currentLevel = currentLevel.concat([newNode]) %}
              {% set currentLevel = newNode.children %}
            {% endif %}
          {% endif %}
        {% endfor %}
      {% endif %}
    {% endfor %}
    
    {# 渲染分类树 #}
    <ul class="category-list-list">
      {% for node in root %}
        {% include '_partials/category-item.swig' %}
      {% endfor %}
    </ul>
  </div>
</div>
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
