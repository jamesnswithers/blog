---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
---

<ul class="fa-ul">
  {% for post in site.posts %}
    <li>
    {% if post.category == 'hiking' %}
    <span class="fa-li"><i class="fa-solid fa-person-walking"></i></span>
    {% else %}
    <span class="fa-li"><i class="fa-solid fa-minus"></i></span>
    {% endif %}
      <a href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
      <br />
      <br />
      <img src="{{ site.baseurl }}/assets/img/{{ post.route }}-route.png" alt="{{ post.route | capitalize }} Route">
      Distance: <code>{{ post.distance }}</code> | Grade: <code>{{ post.grade }}</code> | Dog: <code>{{ post.dogFriendliness }}</code>
      <br />
      <br />
      <hr />
    </li>
  {% endfor %}
</ul>
