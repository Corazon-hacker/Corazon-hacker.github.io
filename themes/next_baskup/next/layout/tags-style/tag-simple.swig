<font size=100 color= #ff6>aaaaaa</font>
<div class="atag-cloud">
    
    <div class="atag-cloud-title">
    {{ _p('counter.tag_cloud', site.tags.length) }}
    </div>
    <div class="atag-cloud-tags">
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
<style>
.atag-cloud {
  text-align: center;
  margin-top: 20px;
}
.atag-cloud-title {
  font-size: 1.8rem;
  text-align: center;
}
.atag-cloud-tags {
  text-align: center;
}
.atag-cloud-tags a {
  display: inline-block;
  margin: 0 0.4rem;
  text-decoration: none;
  font-weight: normal;
  font-size: 15px;
  cursor: pointer;
  line-height: normal;
  padding: 5px 5px 5px 10px;
  position: relative;
  border-radius: 0 5px 5px 0;
  -webkit-transition: all 0.3s;
  -moz-transition: all 0.3s;
  -o-transition: all 0.3s;
  -ms-transition: all 0.3s;
  transition: all 0.3s;
}
.atag-cloud-tags a:hover {
  color: #ff7242 !important;
  -webkit-transform: scale(1.1);
  -moz-transform: scale(1.1);
  -o-transform: scale(1.1);
  -ms-transform: scale(1.1);
  transform: scale(1.1);
}
</style>