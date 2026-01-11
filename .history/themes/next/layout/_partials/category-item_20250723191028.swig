<li class="category-list-list-item">
  <div class="category-header {% if node.children and node.children.length > 0 %}has-children{% endif %}" 
       {% if node.fullName %}data-fullname="{{ node.fullName }}"{% endif %}>
    {% if node.children and node.children.length > 0 %}
      <i class="fa fa-caret-right category-toggle-icon"></i>
    {% endif %}
    
    {% if node.path %}
      <a class="category-list-list-link" href="{{ url_for(node.path) }}">
        {{ node.name || '未命名分类' }}
      </a>
    {% else %}
      <span class="category-list-list-link">{{ node.name || '未命名分类' }}</span>
    {% endif %}
    
    <span class="category-list-list-count" 
          data-original-count="{{ node.length || 0 }}">
      {{ node.length || 0 }}
    </span>
  </div>
  
  {% if node.children and node.children.length > 0 %}
    <ul class="category-list-child">
      {% for child in node.children %}
        {% include '_partials/category-item.swig' with { node: child } %}
      {% endfor %}
    </ul>
  {% endif %}
</li>