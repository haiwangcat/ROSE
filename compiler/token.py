class Token: 
    def __init__(self,ttype,value,lineno,lexpos):
        # print "token=",ttype,value,lineno,lexpos
        self.type = ttype
        self.value = value
        self.lineno = lineno
        self.lexpos = lexpos
    def __str__(self):
        return "LexToken(%s,%r,%d,%d)" % (self.type,self.value,self.lineno,self.lexpos)
    def __repr__(self):
        return str(self)
