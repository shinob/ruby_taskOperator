class KmrPlans < Model
  
  def initialize()
    set_value($db, "kmrplans")
  end
  
  def show(id)
    
    vals = get_data_by_id(id)
    task_id = vals["task_id"]
    
    return get_show_form(vals, task_id)
    
  end
  
  def edit(id)
    
    vals = get_data_by_id(id)
    task_id = vals["task_id"]
    
    return get_edit_form(vals, task_id)
    
  end
  
  def add(task_id)
    
    vals = get_blank_data()
    vals["add_date"] = Date.today.strftime("%Y-%m-%d")
    vals["status"] = "未着手"
    return get_edit_form(vals, task_id)
    
  end
  
  def list(task_id)
    sql = "SELECT * FROM #{@table} WHERE task_id = #{task_id} ORDER BY add_date"
    vals = @db.query(sql)
    return get_list_table(vals)
  end
  
  def list_all()
    
    return get_list_table(get_data_with_order("add_date"))
    
  end
  
  def get_task_id(id)
    
    return get_value_by_id("task_id", id)
    
  end
  
  def set_status(id, status)
    vals = {}
    vals["id"] = id
    vals["status"] = status
    apply(vals)
  end
  
  def get_task_status(task_id)
    sql = "SELECT * FROM #{@table} WHERE task_id = #{task_id} ORDER BY add_date"
    vals = @db.query(sql)
    count = vals.length
    complete = 0
    vals.each do |row|
      if row["status"] == "完了" then
        complete += 1
      end
    end
    
    str = "0 %"
    if count > 0 then
      str = "#{complete * 100 / count} %"
    end
    
    return str
    
  end
  
  def get_show_form(vals, task_id)
    
    vals["complete"] = vals["complete"].gsub("\r","<br />")
    
    tsk = KmrTasks.new()
    
    tmp = tsk.get_data_by_id(task_id)
    
    vals["task_id"] = task_id
    vals["task_title"] = tmp["title"]
    vals["task_note"] = tmp["note"].gsub("\r","<br />")
    
    vals["user_id"] = $usr.get_disp_name(vals["user_id"])
    
    html = load_template(vals, "show_plan.html")
    return html
    
  end
  
  def get_edit_form(vals, task_id)
    
    tsk = KmrTasks.new()
    
    tmp = tsk.get_data_by_id(task_id)
    
    vals["task_id"] = task_id
    vals["task_title"] = tmp["title"]
    vals["task_note"] = tmp["note"].gsub("\r","<br />")
    
    vals["user_id"] = $usr.get_user_select_form(vals["user_id"])
    
    html = load_template(vals, "edit_plan.html")
    return html
    
  end
  
  def get_list_table(vals)
    
    act = KmrActions.new()
    
    html = ""
    #html = get_add_form()
    
    color = "#EEE"
    
    vals.each do |row|
      
      row["complete"] = row["complete"].gsub("\r","<br />")
      disp_name = $usr.get_disp_name(row["user_id"])
      color = (color == "#FFF") ? "#EEE" : "#FFF"
      
      html += <<EOF
<div style="background-color: #{color};">
<div
  onMouseOver="this.className='plan_list_onmouseover';"
  onMouseOut="this.className='plan_list_onmouseout';"
  onClick="this.className='plan_list_onmouseout'; document.edit_plan_#{row["id"]}.submit();"
>
<form method='post' name='edit_plan_#{row["id"]}'>
  <input type="hidden" name="id" value="#{row['id']}" />
  <input type="hidden" name="task_id" value="#{row['task_id']}" />
  <input type="hidden" name="mode" value="show_plan" />
  <h1>#{row["title"]}</h1>
  <p>#{row["complete"]}</p>
  <p>状況 [#{row["status"]}] #{row["add_date"]} [#{disp_name}] </p>
</form>
</div>
#{act.list(row["id"])}
</div>
EOF
    end
    
    if html != "" then
      html = "<div class='plan_list'><div class='title'>プランとアクション</div>#{html}</div>"
    end
    
    return html
    
  end
  
end
    
