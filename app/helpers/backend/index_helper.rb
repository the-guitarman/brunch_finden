module Backend::IndexHelper

  def filters_to_active_relation(ar, filters)
    active_relation = ar
    this_ar_arel_table = active_relation.arel_table

    filters.each{|filter_array|
      Rails.logger.info('Next filter')

      filter = filter_array[1] #
      field = filter['field'].split('__')
      column_name = field.length==1 ? field.first : field.last
      ar_class_name = field.length==1 ?  nil : field.first

      unless ar_class_name
        if filter['dbTable'].blank?
          arel_table = active_relation.arel_table
        else
          arel_table = Arel::Table.new(filter['dbTable'])
        end
      else
        arel_table = ar_class_name.constantize.arel_table
      end

      unless this_ar_arel_table.name==arel_table.name
        active_relation = active_relation.includes(arel_table.name.singularize)
      end
      #Rails.logger.info('123:'+active_relation.where(arel_table[column_name].eq(filter['value'])).class.to_s)
      #active_relation = active_relation.where(arel_table[column_name].eq(filter['data']['value']))

      if filter['data']['type']=='boolean' #convert string to int for booleans
        filter['data']['value'] =  filter['data']['type']=='true' ? 1 : 0
      end

      if filter['data']['type']=='date'
        case filter['data']['comparison']
        when 'gt'
          time = Time.parse(filter['data']['value']).end_of_day
          Rails.logger.info('gt time:'+time.to_s+','+arel_table[column_name].gt(time).to_sql)

          active_relation = active_relation.where(arel_table[column_name].gt(time))
        when 'lt'
          time = Time.parse(filter['data']['value']).beginning_of_day
          Rails.logger.info('lt time:'+time.to_s+','+arel_table[column_name].lt(time).to_sql)

          active_relation = active_relation.where(arel_table[column_name].lt(time))
        else # at this day
          start_time = Time.parse(filter['data']['value']).beginning_of_day
          end_time = Time.parse(filter['data']['value']).end_of_day

          Rails.logger.info('at time:'+start_time.to_s + ';' + end_time.to_s)

          active_relation = active_relation.where(arel_table[column_name].gteq(start_time)).where(arel_table[column_name].lteq(end_time))
        end
      else
        if filter['data']['comparison']
          active_relation = active_relation.where(arel_table[column_name].send(filter['data']['comparison'].to_sym,(filter['data']['value'])))
        else
          active_relation = active_relation.where(arel_table[column_name].eq(filter['data']['value']))
        end
      end

      Rails.logger.info('arel_table:'+arel_table.name)
      Rails.logger.info('filter:'+filter.inspect)
    }
    return active_relation
  end

  def conditions_filter(ext_filter)
    filter_tokens = Array.new(7, '')
    ext_filter.each do |filter_array|
      filter=filter_array[1]
      field=filter['field'].split('__')
      if filter['dbTable'].blank?
        field=field.last
      else
        field="#{filter['dbTable']}.#{field.last}"
      end
      value=filter['data']['value']
      case filter['data']['type']
        when 'boolean'
          unless filter_tokens[0].empty?
            filter_tokens[0] += ' AND '
          end
          if value == 'true'
            filter_tokens[0] += "#{field} = 1"
          else
            filter_tokens[0] += "#{field} = 0"
          end
        when 'date'
          unless filter_tokens[1].empty?
            filter_tokens[1] += ' AND '
          end
          comparision = filter['data']['comparison']
          if comparision == 'eq'
            operation = '='
          elsif comparision == 'gt'
            operation = '>'
          else
            operation = '<'
          end
          date_time = DateTime.strptime(value,"%m/%d/%Y")
          filter_tokens[1] += "#{field} #{operation} '#{date_time.strftime('%Y-%m-%d')}'"
        when 'list'
          unless filter_tokens[2].empty?
            filter_tokens[2] += ' OR '
          end
          filter_tokens[2] += "#{field} = '#{value}'"
        when 'numeric'
          unless filter_tokens[3].empty?
            filter_tokens[3] += ' AND '
          end
          comparision = filter['data']['comparison']
          if comparision == 'eq'
            operation = '='
          elsif comparision == 'gt'
            operation = '>'
          else
            operation = '<'
          end
          filter_tokens[3] += "#{field} #{operation} #{value}"
        when 'string'
          unless filter_tokens[4].empty?
            filter_tokens[4] += ' AND '
          end
          filter_tokens[4] += "#{field} LIKE '%#{value}%'"
        else
          unless filter_tokens[5].empty?
            filter_tokens[5] += ' AND '
          end
          filter_tokens[5] += "#{field}=#{value}"
      end
    end

    filter_string = ''
    filter_tokens.each do |filter_type|
      unless filter_type.empty?
        unless filter_string.empty?
          filter_string += ' AND '
        end
        filter_string += "(#{filter_type})"
      end
    end
    return filter_string
  end

  def bulk_deletion(object_class, property_unit_ids = false, add_return_data = {})
    error_msgs = []; error_ids = []; processed_objects = []
    error = false
    property_unit_ids = params[:ids].split(',') unless property_unit_ids
    property_unit_ids.each do |id|
      if object = object_class.find_by_id(id)
        if object.destroy.frozen?
          processed_objects << object
        else
          message = ''
          object.errors.each do |key,value|
            if message.empty?
              message = value
            else
              message += ", #{value}"
            end
          end
          error_msgs.push(message)
          error_ids << id
          error = true
        end
      else
        error_msgs.push("#{object.class.name} '#{id}' was not found!")
        error_ids << id
        error = true
      end
    end
    return_data = {}
    if error
      return_data = {
        :error => true,
        :count => error_msgs.length,
        :error_msgs => error_msgs,
        :error_ids => error_ids,
        :objects => processed_objects
      }
    else
      return_data = {:error => false, :objects => processed_objects}
    end
    return_data.update(add_return_data)
    render :json => [return_data].to_json
  end
end
