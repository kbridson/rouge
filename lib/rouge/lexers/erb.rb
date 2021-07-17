# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class ERB < TemplateLexer
      title "ERB"
      desc "Embedded ruby template files"

      tag 'erb'
      aliases 'eruby', 'rhtml'

      filenames '*.erb', '*.erubis', '*.rhtml', '*.eruby'

      def initialize(opts={})
        @ruby_lexer = Ruby.new(opts)

        super(opts)
      end

      start do
        parent.reset!
        @ruby_lexer.reset!
      end

      open  = /<%%|<%=|<%#|<%-|<%/
      close = /%%>|-%>|%>/

      open_mark = /<mark>/
      close_mark = /<\/mark>/

      state :root do
        rule open_mark, Mark, :marked
        
        rule %r/<%#/, Comment, :comment

        rule open, Comment::Preproc, :ruby

        rule %r/^(?!#{open_mark}).+?(?=#{open})|.+/m do
          delegate parent
        end
      end

      state :marked do
        rule close_mark, Mark, :pop!
        rule %r/.+?(?=#{close_mark})|.+/m, Mark
      end

      state :comment do
        rule close, Comment, :pop!
        rule %r/.+?(?=#{close})|.+/m, Comment
      end

      state :ruby do
        rule close, Comment::Preproc, :pop!

        rule %r/.+?(?=#{close})|.+/m do
          delegate @ruby_lexer
        end
      end
    end
  end
end
