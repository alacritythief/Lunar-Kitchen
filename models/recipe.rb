class Recipe
  attr_reader :find
  attr_accessor :id, :name, :description, :ingredients, :instructions

  def initialize(id, name, description, ingredients, instructions)
    @id = id
    @name = name

    if description == nil
      @description = "This recipe doesn't have a description."
    else
      @description = description
    end

    @ingredients = []

    if instructions == nil
      @instructions = "This recipe doesn't have any instructions."
    else
      @instructions = instructions
    end
  end

  def self.all
    recipes = []
    query = "SELECT name, id FROM recipes ORDER BY name"
    data = Import.sql(query)
    data.each do |recipe|
      recipes << Recipe.new(recipe["id"],recipe["name"], nil, nil, nil)
    end

    return recipes
  end

  def self.find(id)

    ingredients_query = "
    SELECT ingredients.name FROM ingredients
    WHERE ingredients.recipe_id = #{id}"

    recipe_query = "
    SELECT name, instructions, description FROM recipes
    WHERE id = #{id}"

    ingredients = []
    recipe = nil

    recipe_data = Import.sql(recipe_query)
    ingredients_data = Import.sql(ingredients_query)

    ingredients_data.each do |ingredient|
      ingredients << Ingredient.new(ingredient["name"])
    end

    recipe_data.each do |row|
      recipe = Recipe.new(id, row["name"], row["description"], nil, row["instructions"])
    end

    recipe.ingredients = ingredients
    return recipe
  end
end

class Import
  def self.connect
    begin
      connection = PG.connect(dbname: 'recipes')
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.sql(query)
    self.connect do |conn|
      result = conn.exec_params(query)
    end
  end
end
