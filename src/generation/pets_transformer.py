import logging 
import ontoweaver
from ontoweaver import types as owtypes

class pets_transformer(ontoweaver.transformer.Transformer):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
#        self.declare = ontoweaver.base.Declare(raise_errors = kwargs["raise_errors"])
        self.declare_types.make_node_class("cat")
        self.declare_types.make_node_class("dog")
        self.declare_types.make_node_class("animal")
        self.declare_types.make_edge_class("hasPet", getattr(owtypes, "person"), getattr(owtypes, "animal"))

    def __call__(self, row, i):
        pets = str(row["pets"])
        if pets != "nan":
            for pet in pets.split(";"):
                node_value, node_type = pet.split("(")
                node_type = node_type.replace(")", "")#.capitalize()
                yield node_value, getattr(owtypes, "hasPet"), getattr(owtypes, node_type), None
        
        
