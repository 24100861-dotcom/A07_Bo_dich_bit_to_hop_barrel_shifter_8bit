def model(a,b,op):
    if op==0:
        t=a+b; y=t&255
        v=int(((a>>7)&1)==((b>>7)&1) and ((y>>7)&1)!=((a>>7)&1))
    elif op==1:
        y=(a-b)&255
        v=int(((a>>7)&1)!=((b>>7)&1) and ((y>>7)&1)!=((a>>7)&1))
    elif op==2:
        y=a&b; v=0
    elif op==3:
        y=a|b; v=0
    else:
        y=0; v=0
    return y,int(y==0),(y>>7)&1,v

def run():
    for a in range(256):
        for b in range(256):
            for op in range(4):
                y,z,n,v=model(a,b,op)
                assert z==int(y==0)
                assert n==(y>>7)&1
                assert v in (0,1)
    print("A07 independent Python model: PASS")

if __name__=="__main__":
    run()
