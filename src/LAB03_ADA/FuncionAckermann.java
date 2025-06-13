
package LAB03_ADA;

import java.util.Scanner;
import java.util.Stack;

/**
 *
 * @author MATHIAS TORRES LEZAMA
 */
public class FuncionAckermann {
    
    public static int funcionAckermann(int m, int n){
        Stack<Integer> stack = new Stack<>();
        stack.push(m);
        
        while(!stack.isEmpty()){
            
            m = stack.pop();
            
            if(m == 0){
                n = n+1;
            } else if(m > 0 && n == 0){
                n = 1;
                stack.push(m-1);
            }else if(m > 0 && n > 0){
                stack.push(m-1);
                stack.push(m);
                
                n = n-1;
            }
        }
        return n;
    }
    
    public static void main(String[] args){
        Scanner scanner = new Scanner(System.in);

        System.out.print("Primer argumento para la funcion Ackermann (m): ");
        int m = scanner.nextInt();

        System.out.print("Segundo argumento para la funcion Ackermann (n): ");
        int n = scanner.nextInt();

        int resultado = funcionAckermann(m, n);

        System.out.printf("Ackermann Iterativo(%d, %d) = %d\n", m, n, resultado);

        scanner.close();
    }
}
