class KmrActions < Model
  
  def initialize()
    set_value($db, "kmractions")
  end
  
  def show(id)
    
    vals = get_data_by_id(id)
    task_id = vals["task_id"]
    
    return get_show_form(vals, task_id)
    
  end
  
  def edit(id)
    
    vals = get_data_by_id(id)
    plan_id = vals["plan_id"]
    
    return get_edit_form(vals, plan_id)
    
  end
  
  def add(plan_id)
    
    vals = get_blank_data()
    
    return get_edit_form(vals, plan_id)
    
  end
  
  def list(plan_id)
    sql = "SELECT * FROM #{@table} WHERE plan_id = #{plan_id} ORDER BY add_date"
    vals = @db.query(sql)
    return get_list_table(vals)
  end
  
  def list_all()
    
    return get_list_table(get_data_with_order("add_date"))
    
  end
  
  def get_task_id(id)
    
    return get_value_by_id("task_id", id)
    
  end
  
  def get_status_select_form(status)
    
    types = ["未着手", "対応中", "延期", "完了"]
    
    html = "<SELECT name='status'>"
    types.each do |str|
      tmp = (str==status) ? "selected" : ""
      html += "<OPTION value='#{str}' #{tmp}>#{str}</OPTION>"
    end
    html += "</SELECT>"
    return html
    
  end
  
  def get_edit_form(vals, plan_id)
    
    vals["status"] = get_status_select_form(vals["status"])
    
    pln = KmrPlans.new()
    
    tmp = pln.get_data_by_id(plan_id)
    
    vals["plan_id"] = plan_id
    vals["plan_title"] = tmp["title"]
    vals["plan_complete"] = tmp["complete"].gsub("\r","<br />")
    
    vals["user_id"] = $usr.get_user_select_form(vals["user_id"])
    
    html = load_template(vals, "edit_action.html")
    return html
    
  end
  
  def get_list_table(vals)
    
    html = ""
    #html = get_add_form()
    
    color = "#EEE"
    
    vals.each do |row|
      
      row["note"] = row["note"].gsub("\r","<br />")
      disp_name = $usr.get_disp_name(row["user_id"])
      color = (color == "#FFF") ? "#EEE" : "#FFF"
      
      html += <<EOF
<a href="#" onClick="document.edit_action_#{row["id"]}.submit();">
<form method='post' name='edit_action_#{row["id"]}'>
  <input type="hidden" name="id" value="#{row['id']}" />
  <input type="hidden" name="plan_id" value="#{row['plan_id']}" />
  <input type="hidden" name="mode" value="edit_action" />
  <h1>#{row["note"]}</h1>
  <p>#{row["add_date"]} [#{disp_name}] #{row["status"]}</p>
</form>
</a>
EOF
    end
    
    if html != "" then
      html = "<div class='action_list'><div class='title'>アクション</div>#{html}</div>"
    end
    
    return html
    
  end
  
end
    
