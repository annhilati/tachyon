import net.minecraft.client.renderer.PostPass;
public class Test {
    public static void main(String[] args) {
        for (java.lang.reflect.Field f : PostPass.class.getDeclaredFields()) {
            System.out.println(f.getType().getName() + " " + f.getName());
        }
        for (java.lang.reflect.Method m : PostPass.class.getDeclaredMethods()) {
            System.out.println(m.getReturnType().getName() + " " + m.getName());
        }
    }
}
