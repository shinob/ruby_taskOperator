class KmrTasks < Model
  
  def initialize()
    set_value($db, "kmrtasks")
  end
  
  def show(id)
    
    vals = get_data_by_id(id)
    vals["user_id"] = $usr.get_disp_name(vals["user_id"])
    return get_show_form(vals)
    
  end
  
  def edit(id)
    
    vals = get_data_by_id(id)
    return get_edit_form(vals)
    
  end
  
  def add()
    
    vals = get_blank_data()
    return get_edit_form(vals)
    
  end
  
  def get_edit_form(vals)
    
    vals["user_id"] = $usr.get_user_select_form(vals["user_id"])
    
    html = load_template(vals, "edit_task.html")
    return html
    
  end
  
  def set_status(id, status)
    vals = {}
    vals["id"] = id
    vals["status"] = status
    apply(vals)
  end
  
  def get_show_form(vals)
    
    vals["note"] = vals["note"].gsub("\r","<br />")
    vals["tags"] += "&nbsp;"
    html = load_template(vals, "show_task.html")
    return html
    
  end
  
  def list_all()
    
    return get_list_table(get_data_with_order("add_date"))
    
  end
  
  def list_not_complete()
    
    sql = "SELECT * FROM #{@table} WHERE status != '100 %' ORDER BY add_date"
    vals = @db.query(sql)
    
    return get_list_table(vals)
    
  end
  
  def get_list_table(vals)
    
    html = ""
    #html = get_add_form()
    
    color = "#EEE"
    
    vals.each do |row|
      
      disp_name = $usr.get_disp_name(row["user_id"])
      color = (color == "#FFF") ? "#EEE" : "#FFF"
      
      html += <<EOF
<a href="#" onClick="document.edit_task_#{row["id"]}.submit();">
<form method='post' name='edit_task_#{row["id"]}'>
  <input type="hidden" name="id" value="#{row['id']}" />
  <input type="hidden" name="mode" value="show_task" />
  <h1>#{row["title"]}</h1>
  <div>#{row["add_date"]} [#{disp_name}] #{row["status"]}</div>
</form>
</a>
EOF
    end
    
    if html != "" then
      html = "<div class='task_list'>#{html}</div>"
    end
    
    return html
    
  end
  
end
    