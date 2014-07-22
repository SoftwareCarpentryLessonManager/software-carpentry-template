# _plugins/include_patch.rb
module Jekyll
module Tags

  class IncludeTag < Liquid::Tag
    def render(context)
      #@file = context[@file] || @file # <- this was the patch from https://github.com/jekyll/jekyll/issues/176 (we ignore it)
      includes_dir = File.join(context.registers[:site].source, 'template/_includes')
      # above, we replace the hardcoded _includes by template/_includes

      if File.symlink?(includes_dir)
        return "Includes directory '#{includes_dir}' cannot be a symlink"
      end 

      if @file !~ /^[a-zA-Z0-9_\/\.-]+$/ || @file =~ /\.\// || @file =~ /\/\./
        return "Include file '#{@file}' contains invalid characters or sequences"
      end 

      Dir.chdir(includes_dir) do
        choices = Dir['**/*'].reject { |x| File.symlink?(x) }
        if choices.include?(@file)
          source = File.read(@file)
          partial = Liquid::Template.parse(source)
          context.stack do
            partial.render(context)
          end 
        else
          "Included file '#{@file}' not found in _includes directory"
        end 
      end 
    end 
  end 

end
end
