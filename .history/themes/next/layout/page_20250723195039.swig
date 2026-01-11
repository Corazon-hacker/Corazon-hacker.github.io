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
{% elif page.type === 'categories' %}
{% for category in site.categories.toArray() %}
  <p>{{ category.name }} - {{ category.length }}篇文章</p>
{% endfor %}
<div class="category-all-page">
  <div class="category-all-title">
    {{ _p('counter.categories', site.categories.length) }}
  </div>
  <div class="category-all" id="categoryContainer">
    {{ list_categories() }}
  </div>
  
  {# 文章列表区域 #}
  <div id="categoryPostsContainer" class="category-posts-container" style="display: none;">
    <div class="posts-collapse">
      <div class="collection-title">
        <h2 class="collection-header">
          <span id="currentCategoryName"></span>
          <small>{{ __('title.category') }}</small>
        </h2>
      </div>
      <div id="categoryPostsList"></div>
    </div>
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
