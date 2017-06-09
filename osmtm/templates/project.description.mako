<%namespace file="helpers.mako" name="helpers"/>
<%
from osmtm.mako_filters import markdown_filter
%>
% if project.status in [project.status_draft, project.status_archived] :
<p class="alert alert-warning text-muted">
  <span class="glyphicon glyphicon-warning-sign"></span>
  % if project.status == project.status_draft:
    ${_('This project is not published yet.')}
    % if user and user.is_project_manager:
    <a href="${request.route_url('project_publish', project=project.id)}" class="pull-right">
      <span class="glyphicon glyphicon-share-alt"></span> ${_('Publish')}
    </a>
    % endif
  % elif project.status == project.status_archived:
    ${_('This project was archived.')}
  % endif
</p>
% endif
<p>${project.description | markdown_filter, n}</p>
<p>
% for label in project.labels:
${helpers.display_label(label)}
% endfor
<br>
${helpers.display_project_info(project=project)}
</p>
<p class="text-center">
  <a class="btn btn-success btn-lg instructions">
    <span class="glyphicon glyphicon-share-alt"></span>&nbsp;
    ${_('Instructions')}</a>
</p>

<div class="table-responsive">
  <table class="table">
    <thead>
      <tr>
        <th>User</th>
        <th>Contributions</th>
      </tr>
    </thead>
    <tbody>
      % for user_id, num in contributions:
        <tr>
          <td>${user_id}</td>
          <td>${num}</td>
        </tr>
      % endfor
    </tbody>
  </table>
</div>
