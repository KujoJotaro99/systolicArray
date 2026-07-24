class ProcessingElement:
    def __init__(self, weight):
        self.weight = weight

    def step(self, a, b):
        c = a
        d = a * self.weight + b
        return c, d
