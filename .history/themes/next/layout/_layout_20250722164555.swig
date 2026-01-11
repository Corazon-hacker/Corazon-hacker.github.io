<!DOCTYPE html>
<html lang="{{ config.language }}">
<head>
  {{ partial('_partials/head/head.swig', {}, {cache: theme.cache.enable}) }}
  {% include '_partials/head/head-unique.swig' %}
  {{- next_inject('head') }}
  <title>{% block title %}{% endblock %}</title>
     <!-- 球型气泡标签云 -->
   <script type="text/javascript" src="/js/tag/bubble.js"></script>
  {{ partial('_third-party/analytics/index.swig', {}, {cache: theme.cache.enable}) }}
  
  {{ partial('_scripts/noscript.swig', {}, {cache: theme.cache.enable}) }}
  {% if page.type === 'categories' %}
  <script src="/js/myjs.js"></script>
  {% endif %} 
</head>


<body itemscope itemtype="http://schema.org/WebPage">
  <div class="container{%- if theme.motion.enable %} use-motion{%- endif %}">
    <div class="headband"></div>

    <header class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner">{% include '_partials/header/index.swig' %}</div>
    </header> 

    {{ partial('_partials/widgets.swig', {}, {cache: theme.cache.enable}) }}

    <main class="main">
      <div class="main-inner">
        <div class="content-wrap">
          {% include '_partials/header/sub-menu.swig' %}
          <div class="content {% block class %}{% endblock %}">
            {% block content %}{% endblock %}
          </div>
          {% include '_partials/comments.swig' %}
        </div>
        {%- if theme.sidebar.display !== 'remove' %}
          {% block sidebar %}{% endblock %}
        {%- endif %}
      </div>
    </main>
    {#<div class="dynamic-cube">#}
    {#{% include 'dynamic-cube.swig' %}#}
    </div>
    <footer class="footer">
      <div class="footer-inner">
        {% include '_partials/languages.swig' %}
        {{ partial('_partials/footer.swig', {}, {cache: theme.cache.enable}) }}
        {{ partial('_third-party/statistics/index.swig', {}, {cache: theme.cache.enable}) }}
      </div>
    </footer>
  </div>

  {{ partial('_scripts/index.swig', {}, {cache: theme.cache.enable}) }}
  {{ partial('_third-party/index.swig', {}, {cache: theme.cache.enable}) }}

  {%- if theme.pjax %}
    <div id="pjax">
  {%- endif %}
  {% include '_third-party/math/index.swig' %}
  {% include '_third-party/quicklink.swig' %}

  {{- next_inject('bodyEnd') }}
  {%- if theme.pjax %}
    </div>
  {%- endif %}


  <script>
  (function(){
     var bp = document.createElement('script');
      var curProtocol = window.location.protocol.split(':')[0];
      if (curProtocol === 'https') {
          bp.src = 'https://zz.bdstatic.com/linksubmit/push.js';        
      }
      else {
          bp.src = 'http://push.zhanzhang.baidu.com/push.js';
      }
      var s = document.getElementsByTagName("script")[0];
      s.parentNode.insertBefore(bp, s);
  })();
  </script>
<!-- gitalk.swig -->
<link href="https://cdn.bootcss.com/gitalk/1.4.0/gitalk.min.css" rel="stylesheet" />
<script src="https://cdn.bootcss.com/gitalk/1.4.0/gitalk.min.js"></script>
<script src="https://cdn.bootcss.com/blueimp-md5/2.10.0/js/md5.min.js"></script>
<script type="text/javascript">
  var gitalk = new Gitalk({
    clientID: '{{ theme.gitalk.ClientID }}',
    clientSecret: '{{ theme.gitalk.ClientSecret }}',
    repo: '{{ theme.gitalk.repo }}',
    owner: '{{ theme.gitalk.owner }}',
    admin: ['{{ theme.gitalk.adminUser }}'],
    id: md5(location.pathname),   // ISSUE：location.href 限制50个字符 (应该是Issue 内容存数据库的标识， 具体在页面上无感)
    labels: '{{ theme.gitalk.labels }}'.split(',').filter(l => l),  // 需要的 labels需要一个数组，否则会报错
    perPage: {{ theme.gitalk.perPage }},
    pagerDirection: '{{ theme.gitalk.pagerDirection }}',
    createIssueManually: {{ theme.gitalk.createIssueManually }},
    distractionFreeMode: {{ theme.gitalk.distractionFreeMode }}
  })
  gitalk.render('gitalk-container')
</script>

  
</body>
</html>
