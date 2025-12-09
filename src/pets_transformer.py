import logging 
import ontoweaver
from ontoweaver import types as owtypes

class pets_transformer(ontoweaver.transformer.Transformer):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
#        self.declare = ontoweaver.base.Declare(raise_errors = kwargs["raise_errors"])
        self.declare_types.make_node_class("Cat")
        self.declare_types.make_node_class("Dog")
        self.declare_types.make_node_class("Animal")
        print(dir(owtypes))
        self.declare_types.make_edge_class("has_pet", getattr(owtypes, "person"), getattr(owtypes, "Animal"))

    def __call__(self, row, i):
        pets = str(row["pets"])
        if pets != "nan":
            print("pets = ", pets)
            for pet in pets.split(";"):
                node_value, node_type = pet.split("(")
                node_type = node_type.replace(")", "").capitalize()
                yield node_value, getattr(owtypes, "has_pet"), getattr(owtypes, node_type), None
        
        
