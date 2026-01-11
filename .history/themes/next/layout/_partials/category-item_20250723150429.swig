<li class="category-list-list-item">
  <div class="category-header">
    {% if category.children | length > 0 %}
      <i class="fa fa-caret-right category-toggle-icon"></i>
    {% endif %}
    <a class="category-list-list-link" href="{{ url_for(category.path) }}">
      {{ category.name }}
    </a>
    <span class="category-list-list-count">{{ category.length }}</span>
  </div>
  
  {% if category.children | length > 0 %}
    <ul class="category-list-child">
      {% for key, child in category.children %}
        {% include '_partials/category-item.swig' with { category: child } %}
      {% endfor %}
    </ul>
  {% endif %}
</li>