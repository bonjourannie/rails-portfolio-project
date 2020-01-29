class Project < ApplicationRecord
    belongs_to :user, :counter_cache => true
    has_many :project_materials 
    has_many :materials, through: :project_materials
    has_many :category_projects
    has_many :categories, through: :category_projects

    validates_presence_of :name, :materials, :instructions
    validates_uniqueness_of :name

    def project_materials_attributes=(project_materials_hash)
		project_materials_hash.values.each do |project_material|
			project = Project.find_by(id: project_material[:project_id])
			proj_material = ProjectMaterial.find_by(id: project_material[:id])
			material = Material.find_by(id: project_material[:material_attributes][:id])
			if project && proj_material && material
				proj_material.update(notes: project_material[:notes])
				material.update(name: project_material[:material_attributes][:name])
			else
				self.project_materials.build(project_material)
			end
		end
	end

    def categories_attributes=(categories_attributes)
        categories_attributes.values.each do |category_attribute|
            if !category_attribute[:name].empty? && category = Category.find_or_create_by(category_attribute)
                self.categories.update(categories_attributes) 
            end
        end
    end

    def self.most_materials 
        left_joins(:materials)
        .group(:id)
        .order('COUNT(materials.id) DESC')
        .limit(1)
    end

    def self.search(search)
        joins(:materials).where({materials: {name: "#{search}"}})
    end
end
