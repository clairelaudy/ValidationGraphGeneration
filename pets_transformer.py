import ontoweaver.tabular as tabular
import ontoweaver

class pets_transformer(ontoweaver.base.Transformer):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.declare = tabular.Declare(raise_errors = kwargs["raise_errors"])

        self.declare.make_node_class("Cat")
        self.declare.make_node_class("Dog")

        self.declare.make_edge_class("has_pet")

    def __call__(self, row, i):
        pets = row["pets"]
        for pet in pets.split(";"):
            node_value, node_type = pet.split("(")
            node_type = node_type.replace(")", "").capitalize()
            yield node_value, "has_pet", node_type, None
        
        
