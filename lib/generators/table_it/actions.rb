module TableIt
  module Generators
    # Moduł rozszerzający możliwości generatorów
    module Actions
 # Wstaw tłumaczenia do pliku
  #
  # * *Argumenty* :
  #   
  #   - +file+ -> nazwa pliku z tłumaczeniami
  #   - +trans+ -> hash z drzewem tłumaczeń
  #   - +path+ -> ścieżka w drzewie tłumaczeń do której podpiąc tłumaczenie,
  #     domyślnie 'pl'
  def translations(file, trans, path = 'pl')
    idt = path.split('.').size
    indent = "  " * idt
    after = path.split('.').zip(1..idt).map do |p, n|
      if n < idt
        p + ":.*\n" + "  " * n
      else
        p + ":\n"
      end
    end.join('')
    after_regex = /#{after}/m
    translation = trans.to_yaml.gsub("\n", "\n#{indent}")[4..-1].rstrip + "\n"
    translation = translation.encode 'ascii-8bit', undef: :replace
    inject_into_file file, translation, after: after_regex, verbose: false
    log :translations, file
  end

  # Utwórz plik z tłumaczeniami
  #
  # * *Argumenty* :
  #   
  #   - +name+ -> nazwa tłumaczonego modułu
  #   - +trans+ -> drzewo tłumaczeń
  #   - +lang+ -> język tłumaczeń
  #
  def translations_file(name, trans, lang = :pl)
    file = ::Rails.root.join('config', 'locales', "#{lang}.yml")
    log :translations, file.relative_path_from(::Rails.root).to_s

    File.open(file, 'a') do |f|
      f << {lang.to_s => {name.downcase.to_s => trans}}.to_yaml( :Indent => 4 )
    end if behavior == :invoke
  end
end
end
end