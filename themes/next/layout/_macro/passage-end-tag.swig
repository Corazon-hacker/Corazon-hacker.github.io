{#//文章结尾加入文字#}
{#//在\themes\next\layout\_macro\post.swig文件，在post-body 之后， post-footer 之前为实现代码（post-footer之前两个DIV）：#}
<div>
    {% if not is_index %}
        <div style="text-align:center;color: #ccc;font-size:14px;">-------------本文结束<i class="fa fa-heart"></i>感谢阅读-------------</div>
    {% endif %}
</div>
