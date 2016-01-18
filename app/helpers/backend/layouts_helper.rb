#encoding: utf-8
module Backend::LayoutsHelper
  private

  def standard_extjs_tool_constants(page)
    ret = page.assign 'BE.EXTJS_DIRECTORY', GLOBAL_CONFIG[:extjs3_url_path]
    ret += page.assign 'BE.APPLICATION_NAME', $application[:name]
    ret += page.assign 'BE.APPLICATION_VERSION', $application[:version]
    ret += page.assign 'BE.APPLICATION_STAGE', $application[:stage]
    ret += page.assign 'BE.APPLICATION_REVISION', APPLICATION_REVISION

    ret += page.assign "BE.login.DOMAIN_NAME", @domain_name
    ret += page.assign "BE.login.FULL_DOMAIN_NAME", @full_domain_name
    ret += page.assign "BE.login.BACKEND", @backend

    user = nil
    if logged_in?
      user = current_user.attributes
      user[:full_name] = current_user.full_name
      unwanted_keys = user.keys.find_all{|k| k.to_s.include?('password') or k.to_s.include?('token')}
      user.except!(*unwanted_keys)
      
      ret += page.assign 'BE.BACKEND_TOOL_GROUPS', @backend_tool_groups
      ret += page.assign 'BE.ACCESSIBLE_BACKEND_TOOLS', @accessible_backend_tools
    end
    ret += page.assign 'BE.CURRENT_USER', user
    ret += page.assign 'BE.backend_user.GENDERS', BackendUser::GENDERS.stringify_keys.sort
    
    ret += page.assign 'BE.DEFAULT_STAGE_CURRENCY', {
      :isoCode   => (I18n.t!('number.currency.format.iso_code') rescue 'GBP'),
      :unit      => (I18n.t!('number.currency.format.unit') rescue '£'),
      :delimiter => (I18n.t!('number.currency.format.delimiter') rescue ','),
      :separator => (I18n.t!('number.currency.format.separator') rescue '.'),
      :precesion => (I18n.t!('number.currency.format.precision') rescue '2'),
      :format    => (I18n.t!('number.currency.format.format') rescue '%u%n')
    }
    ret += page.assign 'BE.DEFAULT_STAGE_NUMBER', {
      :delimiter => (I18n.t!('number.format.delimiter') rescue ','),
      :separator => (I18n.t!('number.format.separator') rescue '.'),
      :precesion => (I18n.t!('number.format.precision') rescue '2')
    }
    ret += page.assign 'BE.DEFAULT_STAGE_DATE', {
      :firstDayOfWeek => (I18n.t!('date.first_day_of_week').to_i rescue 0),
      :default => convert_date_format((I18n.t!('date.formats.default') rescue 'd/m/Y')),
      :short   => convert_date_format((I18n.t!('date.formats.short') rescue 'e b')),
      :long    => convert_date_format((I18n.t!('date.formats.long') rescue 'e B, Y')),
      :dayNames         => (I18n.t!('date.day_names').compact rescue Date::DAYNAMES),
      :abbrDayNames     => (I18n.t!('date.abbr_day_names').compact rescue Date::ABBR_DAYNAMES),
      :monthNames       => (I18n.t!('date.month_names').compact rescue Date::MONTHNAMES),
      :abbrMonthNames   => (I18n.t!('date.abbr_month_names').compact rescue Date::ABBR_MONTHNAMES),
      :order            => (I18n.t!('date.order') rescue [:year, :month, :day])
    }
    ret += page.assign 'BE.DEFAULT_STAGE_TIME', {
      :default => convert_date_format((I18n.t!('time.formats.default') rescue 'a b d H:M:S Z Y')),
      :short   => convert_date_format((I18n.t!('time.formats.short') rescue 'd b H:M')),
      :long    => convert_date_format((I18n.t!('time.formats.long') rescue 'd B, Y H:M')),
      :date    => convert_date_format((I18n.t!('time.formats.date') rescue 'Y-m-d')),
      :time    => convert_date_format((I18n.t!('time.formats.time') rescue 'H:M')),
      :am      => convert_date_format((I18n.t!('time.am') rescue 'am')),
      :pm      => convert_date_format((I18n.t!('time.pm') rescue 'pm'))
    }
    return ret
  end
  
  # Converts a ruby time format string to an extjs date format string.
  def convert_date_format(format = '')
    ret = ''
    characters = format.gsub('%', '').split(//)
    characters.each do |char|
      if char.match(/[a-z]|[A-Z]/)
        ret += _convert_date_format(char)
      else
        ret += char
      end
    end
    return ret
  end
  
  # Converts single ruby time format characters to a
  # single extjs date format characters.
  def _convert_date_format(char)
    ret = case char
      when 'a' then 'D'
      when 'A' then 'l'
      when 'b' then 'M'
      when 'B' then 'F'
      when 'c' then ''
      when 'C' then ''
      when 'd' then 'd'
      when 'D' then ''
      when 'e' then 'j'
      when 'F' then ''
      when 'h' then 'M'
      when 'H' then 'H'
      when 'I' then 'h'
      when 'j' then 'z'
      when 'k' then 'G'
      when 'l' then 'g'
      when 'L' then 'u'
      when 'm' then 'm'
      when 'M' then 'i'
      when 'n' then "\n"
      when 'N' then ''
      when 'p' then 'A'
      when 'P' then 'a'
      when 'r' then ''
      when 'R' then ''
      when 's' then 'U'
      when 'S' then 's'
      when 't' then "\t"
      when 'T' then ''
      when 'u' then 'N'
      when 'U' then 'W'
      when 'v' then ''
      when 'V' then 'W'
      when 'W' then ''
      when 'w' then 'w'
      when 'x' then ''
      when 'X' then ''
      when 'y' then 'y'
      when 'Y' then 'Y'
      when 'z' then 'O'
      when 'Z' then 'T'
      else char
    end
    return ret
  end
end
