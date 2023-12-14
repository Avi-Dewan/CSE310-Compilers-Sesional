#ifndef _astNode_
#define _astNode_

#include<iostream>
#include<string>
#include<vector>
#include"AsmWrite.h"
#include"helper.h"

using namespace std;

class AstNode {
    string type;
    string op;
    AstNode* left;
    AstNode* right;
    string access_by;
    int lineNo;
    int levelNo;

   string getEmptyReg(vector<bool> &reg) {

      if(!reg[0]) {
         reg[0] = true;
         return "BX";
      } else if (!reg[1])
      {
         reg[1] = true;
         return "CX";    
      }else if (!reg[2])
      {        
         reg[2] = true;
         return "DX";
         
      }else if (!reg[3])
      {
         reg[3] = true;
         return "AX";
      }
      
      return "OX";

}

void emptyReg(vector<bool> &regs, string reg) {

   int regIdx = -1;

   if(reg == "BX") {
      regIdx = 0;
   } else if (reg == "CX")
   {
      regIdx = 1;
   } else if (reg == "DX")
   {
      regIdx = 2;
   } else if(reg == "AX") {
      regIdx = 3;
   }

   if(regIdx >= 0 && regIdx <= 3) regs[regIdx] = false;
}


public:

   AstNode(AstNode *left, AstNode *right, string op) {
        this->type = "Binary";
        this->left = left;
        this->right = right;
        this->op = op;
   }

   AstNode(AstNode *left, string op) {
        this->type = "Unary";
        this->left = left;
        this->op = op;
   }

   AstNode(string access_by) {
        this->type = "Terminal";
        this->access_by = access_by;
   }

   string getAccess_by() {
      return access_by;
   }

   void setAccess_by(string access_by) {
      this->access_by = access_by;
   } 

   int getLineNo() {
      return lineNo;
   }

   void setLineNo(int lineNo) {
      this->lineNo = lineNo;
   }

   string asmGenerate(Helper &helper) {

      AsmWrite asmWrite = helper.getAsmWrite();
      vector<bool>&reg = helper.getReg();

      string l = "", r = "", regResult = "";
      

      if(type == "Binary") {


          if(op == "=") {
            
            // left->setAccess_by(r);

            r = right->asmGenerate(helper);

            asmWrite.writeRaw("\tMOV " + left->getAccess_by() + ","  +r);

            emptyReg(reg, l);
            emptyReg(reg, r);

         } else {
            l = left->asmGenerate(helper);
            r = right->asmGenerate(helper);

         }
      

         if(op == "+") {

            asmWrite.writeRaw("\tADD " + l + "," + r);

            emptyReg(reg, r);

            regResult = l;

         } else if(op == "-") {

            asmWrite.writeRaw("\tSUB " + l + "," + r);

            emptyReg(reg, r);

            regResult = l;

         } else if(op == "*") {

            
            if(l == "AX") {

               if(r == "DX") {

                  if(!reg[0]) {
                     asmWrite.writeRaw("\tMOV BX,DX\n\tMUL BX");
                     reg[0] = false;
                  } else {
                     asmWrite.writeRaw("\tMOV CX,DX\n\tMUL CX");
                     reg[1] = false;             
                  }

               } else {

                     asmWrite.writeRaw("\tMUL "+r);
                     emptyReg(reg, r);
               }

               regResult = "AX";
               reg[3] = true;

            } else if(r == "AX") {

               if(l == "DX") {

                  if(!reg[0]) {
                     asmWrite.writeRaw("\tMOV BX,DX\n\tMUL BX");
                     reg[0] = false;
                  } else {
                     asmWrite.writeRaw("\tMOV CX,DX\n\tMUL CX");
                     reg[1] = false;             
                  }

               } else {

                     asmWrite.writeRaw("\tMUL "+l);
                     emptyReg(reg, l);
               }

               regResult = "AX";
               reg[3] = true;

            } else {

               if(!reg[3]) {

                  asmWrite.writeRaw("\tMOV AX,"+ l);
                  emptyReg(reg, l);

                  if(r == "DX") {

                     if(!reg[0]) {
                        asmWrite.writeRaw("\tMOV BX,DX\n\tMUL BX");
                        reg[0] = false;
                     } else {
                        asmWrite.writeRaw("\tMOV CX,DX\n\tMUL CX");
                        reg[1] = false;             
                     }

                  } else {

                        asmWrite.writeRaw("\tMUL "+r);
                        emptyReg(reg, r);
                  }

                  regResult = "AX";
                  reg[3] = true;


               } else {

                  regResult = getEmptyReg(reg);

                  asmWrite.writeRaw("\tMOV " + regResult + ",AX\n");

                  asmWrite.writeRaw("\tMOV AX,"+ l);
                  asmWrite.writeRaw("\tMOV " + l + "," + regResult);

                  emptyReg(reg, regResult);

                  if(r == "DX") {

                     if(!reg[0]) {
                        asmWrite.writeRaw("\tMOV BX,DX\n\tMUL BX");
                        reg[0] = false;
                     } else {
                        asmWrite.writeRaw("\tMOV CX,DX\n\tMUL CX");
                        reg[1] = false;             
                     }

                  } else {

                        asmWrite.writeRaw("\tMUL "+r);
                        emptyReg(reg, r);
                  }

                  asmWrite.writeRaw("\tMOV DX,AX");
                  asmWrite.writeRaw("\tMOV AX," + l);
                  regResult = "DX";
                  emptyReg(reg, l);

               }
               
            }

            if(regResult != "DX")
               emptyReg(reg, "DX");
            
            
             
         } else if(op == "/") {

            if(l == "AX") {

               if(r == "DX") {

                  if(!reg[0]) {
                     asmWrite.writeRaw("\tMOV BX,DX\n\tCWD\n\tDIV BX");
                     reg[0] = false;
                  } else {
                     asmWrite.writeRaw("\tMOV CX,DX\n\tCWD\n\tDIV CX");
                     reg[1] = false;             
                  }

               } else {

                     asmWrite.writeRaw("\tCWD\n\tDIV "+r);
                     emptyReg(reg, r);
               }

               regResult = "AX";
               reg[3] = true;

            } else if(r == "AX") {

               if(l == "DX") {

                  if(!reg[0]) {
                     asmWrite.writeRaw("\tMOV BX,AX\n\tMOV AX,DX\n\tCWD\n\tCWD\n\tDIV BX");
                     reg[0] = false;
                  } else {
                     asmWrite.writeRaw("\tMOV CX,AX\n\tMOV AX,DX\n\tCWD\n\tCWD\n\tDIV CX");                    
                     reg[1] = false;             
                  }

               } else {

                     asmWrite.writeRaw("\tMOV DX,AX\n\tMOV AX," + l + "\n\tMOV " + l +",DX\n\tCWD\n\tDIV "+ l);
                     emptyReg(reg, l);
               }

               regResult = "AX";
               reg[3] = true;

            } else {

               if(!reg[3]) {

                  asmWrite.writeRaw("\tMOV AX,"+ l);
                  emptyReg(reg, l);

                  if(r == "DX") {

                     if(!reg[0]) {
                        asmWrite.writeRaw("\tMOV BX,DX\n\tCWD\n\tDIV BX");
                        reg[0] = false;
                     } else {
                        asmWrite.writeRaw("\tMOV CX,DX\n\tCWD\n\tDIV CX");
                        reg[1] = false;             
                     }

                  } else {

                        asmWrite.writeRaw("\tCWD\n\tDIV "+r);
                        emptyReg(reg, r);
                  }

                  regResult = "AX";
                  reg[3] = true;


               } else {

                  regResult = getEmptyReg(reg);

                  asmWrite.writeRaw("\tMOV " + regResult + ",AX\n");

                  asmWrite.writeRaw("\tMOV AX,"+ l);
                  asmWrite.writeRaw("\tMOV " + l + "," + regResult);

                  emptyReg(reg, regResult);

                  if(r == "DX") {

                     if(!reg[0]) {
                        asmWrite.writeRaw("\tMOV BX,DX\n\tCWD\n\tDIV BX");
                        reg[0] = false;
                     } else {
                        asmWrite.writeRaw("\tMOV CX,DX\n\tCWD\n\tDIV CX");
                        reg[1] = false;             
                     }

                  } else {

                        asmWrite.writeRaw("\tCWD\n\tDIV "+r);
                        emptyReg(reg, r);
                  }

                  asmWrite.writeRaw("\tMOV DX,AX");
                  asmWrite.writeRaw("\tMOV AX," + l);
                  regResult = "DX";
                  emptyReg(reg, l);
               }
               
            }

            if(regResult != "DX")

               emptyReg(reg, "DX");
            

         } else if(op == "%") {


            if(l == "AX") {

               if(r == "DX") {

                  if(!reg[0]) {
                     asmWrite.writeRaw("\tMOV BX,DX\n\tCWD\n\tDIV BX");
                     reg[0] = false;
                  } else {
                     asmWrite.writeRaw("\tMOV CX,DX\n\tCWD\n\tDIV CX");
                     reg[1] = false;             
                  }

               } else {

                     asmWrite.writeRaw("\tCWD\n\tDIV "+r);
                     emptyReg(reg, r);
               }

               regResult = "DX";
               reg[2] = true;

            } else if(r == "AX") {

               if(l == "DX") {

                  if(!reg[0]) {
                     asmWrite.writeRaw("\tMOV BX,AX\n\tMOV AX,DX\n\tCWD\n\tCWD\n\tDIV BX");
                     reg[0] = false;
                  } else {
                     asmWrite.writeRaw("\tMOV CX,AX\n\tMOV AX,DX\n\tCWD\n\tCWD\n\tDIV CX");                    
                     reg[1] = false;             
                  }

               } else {

                     asmWrite.writeRaw("\tMOV DX,AX\n\tMOV AX," + l + "\n\tMOV " + l +",DX\n\tCWD\n\tDIV "+ l);
                     emptyReg(reg, l);
               }

               regResult = "DX";
               reg[2] = true;

            } else {

               if(!reg[3]) {

                  asmWrite.writeRaw("\tMOV AX,"+ l);
                  emptyReg(reg, l);

                  if(r == "DX") {

                     if(!reg[0]) {
                        asmWrite.writeRaw("\tMOV BX,DX\n\tCWD\n\tDIV BX");
                        reg[0] = false;
                     } else {
                        asmWrite.writeRaw("\tMOV CX,DX\n\tCWD\n\tDIV CX");
                        reg[1] = false;             
                     }

                  } else {

                        asmWrite.writeRaw("\tCWD\n\tDIV "+r);
                        emptyReg(reg, r);
                  }

                  regResult = "DX";
                  reg[2] = true;


               } else {

                  regResult = getEmptyReg(reg);

                  asmWrite.writeRaw("\tMOV " + regResult + ",AX\n");

                  asmWrite.writeRaw("\tMOV AX,"+ l);
                  asmWrite.writeRaw("\tMOV " + l + "," + regResult);

                  emptyReg(reg, regResult);

                  if(r == "DX") {

                     if(!reg[0]) {
                        asmWrite.writeRaw("\tMOV BX,DX\n\tCWD\n\tDIV BX");
                        reg[0] = false;
                     } else {
                        asmWrite.writeRaw("\tMOV CX,DX\n\tCWD\n\tDIV CX");
                        reg[1] = false;             
                     }

                  } else {

                        asmWrite.writeRaw("\tCWD\n\tDIV "+r);
                        emptyReg(reg, r);
                  }

                  asmWrite.writeRaw("\tMOV AX," + l);
                  regResult = "DX";
                  emptyReg(reg, l);
               }
               
            }
            
            if(regResult != "AX")
               emptyReg(reg, "AX");

         } else if(op == "<") {

            string label = helper.getLabel();

            asmWrite.writeRaw("\tCMP " + l + "," + r + "\n" +
                               "\tJL " + label + "_true\n" + 
                               "\tMOV " + l + ",0\n" +
                               "\tJMP " + label + "_end\n"+
                               label + "_true:\n" +
                               "\tMOV " + l + ",1\n"+
                               label + "_end:\n"
            
            );

            emptyReg(reg, r);
            regResult = l;

             
         } else if(op == "<=") {

            string label = helper.getLabel();

            asmWrite.writeRaw("\tCMP " + l + "," + r + "\n" +
                               "\tJLE " + label + "_true\n" + 
                               "\tMOV " + l + ",0\n" +
                               "\tJMP " + label + "_end\n"+
                               label + "_true:\n" +
                               "\tMOV " + l + ",1\n"+
                               label + "_end:\n"
            
            );

            emptyReg(reg, r);
            regResult = l;

         } else if(op == ">") {


            string label = helper.getLabel();

            asmWrite.writeRaw("\tCMP " + l + "," + r + "\n" +
                               "\tJG " + label + "_true\n" + 
                               "\tMOV " + l + ",0\n" +
                               "\tJMP " + label + "_end\n"+
                               label + "_true:\n" +
                               "\tMOV " + l + ",1\n"+
                               label + "_end:\n"
            
            );

            emptyReg(reg, r);
            regResult = l;
             
         } else if(op == ">=") {

            string label = helper.getLabel();

            asmWrite.writeRaw("\tCMP " + l + "," + r + "\n" +
                               "\tJGE " + label + "_true\n" + 
                               "\tMOV " + l + ",0\n" +
                               "\tJMP " + label + "_end\n"+
                               label + "_true:\n" +
                               "\tMOV " + l + ",1\n"+
                               label + "_end:\n"
            
            );

            emptyReg(reg, r);
            regResult = l;

         } else if(op == "==") {
            string label = helper.getLabel();

            asmWrite.writeRaw("\tCMP " + l + "," + r + "\n" +
                               "\tJE " + label + "_true\n" + 
                               "\tMOV " + l + ",0\n" +
                               "\tJMP " + label + "_end\n"+
                               label + "_true:\n" +
                               "\tMOV " + l + ",1\n"+
                               label + "_end:\n"
            
            );

            emptyReg(reg, r);
            regResult = l;


         } else if(op == "!=") {


            string label = helper.getLabel();

            asmWrite.writeRaw("\tCMP " + l + "," + r + "\n" +
                               "\tJNE " + label + "_true\n" + 
                               "\tMOV " + l + ",0\n" +
                               "\tJMP " + label + "_end\n"+
                               label + "_true:\n" +
                               "\tMOV " + l + ",1\n"+
                               label + "_end:\n"
            
            );

            emptyReg(reg, r);
            regResult = l;
             
         } else if(op == "&&") {

            string label = helper.getLabel();


            asmWrite.writeRaw("\tCMP " + l + ",0\n" +
                           "JE " + label + "_zero\n" +
                           "\tCMP " + r + ",0\n" +
                           "JE " + label + "_zero\n" +
                           "\tMOV " + l + ",1\n" +
                           "\tJMP " + label + "_end\n" +
                           label + "_zero:\n" +
                           "\tMOV " + l + ",0\n" +
                           label + "_end:\n"
            );

            regResult = l;

            emptyReg(reg, r);
             
         } else if(op == "||") {

            string label = helper.getLabel();


            asmWrite.writeRaw("\tCMP " + l + ",1\n" +
                           "JE " + label + "_one\n" +
                           "\tCMP " + r + ",1\n" +
                           "JE " + label + "_one\n" +
                           "\tMOV " + l + ",0\n" +
                           "\tJMP " + label + "_end\n" +
                           label + "_one:\n" +
                           "\tMOV " + l + ",1\n" +
                           label + "_end:\n"
            );

            regResult = l;

            emptyReg(reg, r);
         } 


       } else if (type == "Unary") {
          
         l = left->asmGenerate(helper);

         if(op == "++") {
            asmWrite.writeRaw("\tINC " + left->getAccess_by());
            regResult = l;
            
         } else if(op == "--") {

            asmWrite.writeRaw("\tDEC " + left->getAccess_by());
            regResult = l;

         } else if(op == "+") {

            regResult = l;

         } else if(op == "-") {

            asmWrite.writeRaw("\tNEG " + l);

            regResult = l;
             
         } else if(op == "!") {
            
         }

       
       } else {
         
         regResult = getEmptyReg(reg);

         
         asmWrite.writeRaw("\tMOV " + regResult + "," + access_by);

       }

        return regResult;
   }

   void printAst() {
       if(type == "Binary") {

         //  cout << "<-------------->\n" << endl;
          cout << op << endl;
         //  cout << "--------------" << endl;
          left->printAst();
          cout << "--------------" << endl;
          right->printAst();
         //  cout << "\n<-------------->\n" << endl;

       } else if (type == "Unary") {
          
         //  cout << "<-------------->\n" << endl;
          cout << op << endl;
         //  cout << "--------------" << endl;
          left->printAst();

         //  cout << "\n<-------------->\n" << endl;

       
       } else {
         //  cout << "\n<-------------->\n" << endl;

          cout << access_by <<  endl;
         //  cout << "\n<-------------->\n" << endl;

       }
       
   }

};


#endif