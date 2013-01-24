def all_categories(posts=articles)
  cats = []
  posts.each do |article|
    next if article[:categories].nil?
    cats << article[:categories]
  end
  cats.flatten.compact.uniq
end
# memoize :all_categories

def has_category?(category, article)
  if article[:categories].nil?
    false
  else
    article[:categories].include?(category)
  end
end

def articles_with_category(category, posts=articles)
  posts.select { |article| has_category?(category, article) }
end
# memoize :articles_with_category

def articles_by_category(posts=articles)
  cats = []
  all_categories.each do |cat|
    cats << [cat, articles_with_category(cat)]
  end
  cats
end
# memoize :articles_by_category

def link_categories(cats)
  cats.map do |cat|
    ['<a href="/categories/', cat, '.html">', cat, '</a>'].join
  end
end


def create_category_pages
  articles_by_category.each do |category, posts|
    @items << Nanoc::Item.new(
      "<%= render('category', :category => '#{category}') %>",
      {
        :title => "Posts in #{category}",
        :h1 => "#{category} posts",
        :posts => posts
      },
      "/categories/#{category}",
      :binary => false
    )
  end
end
