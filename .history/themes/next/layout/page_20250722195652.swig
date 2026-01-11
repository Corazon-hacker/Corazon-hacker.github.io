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
        {#{% elif page.type === 'categories' %}
          <div class="category-all-page">
            <div class="category-all-title">
              {{ _p('counter.categories', site.categories.length) }}
            </div>
            <div class="category-all">
              {{ list_categories() }}
            </div>
          </div>#}
          {# 自定义分类页面 #}
          {% elif page.type === 'categories' %}
            <div class="category-all-page">
              <div class="category-all-title">
                {{ _p('counter.categories', site.categories.length) }}
              </div>
              <div class="category-all">
                {# 定义递归宏 #}
                {% macro render_category(category) %}
                  <li class="category-list-item">
                    <div class="category-header">
                      <div class="toggle-icon">
                        {% if category.children and category.children.length %}
                          <i class="fa fa-caret-right"></i>
                        {% endif %}
                      </div>
                      <a class="category-list-link" href="{{ url_for(category.path) }}">
                        {{ category.name }}
                      </a>
                      <span class="category-list-count">{{ category.length }}</span>
                    </div>
                    {% if category.children and category.children.length %}
                      <ul class="category-list-child">
                        {% for child in category.children %}
                          {{ render_category(child) }}
                        {% endfor %}
                      </ul>
                    {% endif %}
                  </li>
                {% endmacro %}
                
                {# 创建分类树 #}
                {% set category_tree = {} %}
                {% for category in site.categories.toArray() %}
                  {% set parts = category.name.split('/') %}
                  {% set current = category_tree %}
                  {% for part in parts %}
                    {% if not current[part] %}
                      {% set current = current | set(part, {
                        "name": part,
                        "path": category.path,
                        "length": category.length,
                        "children": {}
                      }) %}
                    {% endif %}
                    {% set current = current[part].children %}
                  {% endfor %}
                {% endfor %}
                
                {# 渲染分类树 #}
                <ul class="category-list">
                  {% for _, category in category_tree %}
                    {{ render_category(category) }}
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
