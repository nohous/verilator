`define stop $stop
`define checkh(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0x exp=%0x (%s !== %s)\n", `__FILE__,`__LINE__, (gotv), (expv), `"gotv`", `"expv`"); `stop; end while(0);
`define checks(gotv,expv) do if ((gotv) != (expv)) begin $write("%%Error: %s:%0d:  got='%s' exp='%s'\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);

interface class IBottom;
   pure virtual function bit foo();
endclass

interface class IMid;
   pure virtual function string bar();
endclass

class bottom_class implements IBottom;
    string name;

    function new(string name);
        this.name = name;
    endfunction

   virtual function bit foo();
        $display("%s", name);
   endfunction
endclass

class middle_class extends bottom_class implements IMid;
   function new(string name);
       super.new(name);
   endfunction

   virtual function bit foo();
        $display("%s", name);
        return 0;
   endfunction

   virtual function string bar();
        return "123";
   endfunction
endclass

class top_class extends middle_class;
    int i;
    function new(string name, int i);
        super.new(name);
        this.i = i;
    endfunction
endclass

class sky_class extends top_class;
    function new(string name);
        super.new(name, 42);
    endfunction
endclass


module t;/*AUTOARG*/
   // Inputs

   initial begin
        sky_class s = new("ahoj");
        bottom_class b = s;
        top_class t = s;
      `checks( b.name, "ahoj" );
      `checkh( t.i, 42);
      $finish;
   end

endmodule