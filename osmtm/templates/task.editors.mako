<div class="text-center">

  <a href="${request.route_path('task_edit', task=task.id, project=task.project_id)}" class="btn btn-default">
    <i class="glyphicon glyphicon-share-alt"></i> ${_('Edit')}
    </a>

  <div>
    <%
      cookies = request.cookies
      prefered_editor = cookies['prefered_editor'] if 'prefered_editor' in cookies else ''
    %>
  </div>
  <div id="josm_task_boundary_tip" class="help-block small text-left">
    <em>
      <i class="glyphicon glyphicon-info-sign"></i>
      <%
        link_to_gpx_text = _('.gpx file')
        link_to_gpx = '<a href="%s" target="_blank">%s</a>' % (
          request.route_url('task_gpx', project=task.project_id, task=task.id),
          link_to_gpx_text)
      %>
      ${_('Tip: Download the following ${task_gpx_link} and load it in JOSM in order to see the current task boundary',
      mapping={'task_gpx_link': link_to_gpx}) | n}
    </em>
  </div>
</div>
<script>
  osmtm.prefered_editor = "${prefered_editor}";
</script>
<p></p>
