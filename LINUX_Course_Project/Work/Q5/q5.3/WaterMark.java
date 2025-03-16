import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;

public class WaterMark {
    private static final String WATERMARK_TEXT1 = "Lotem Tubul 206436420";
    private static final String WATERMARK_TEXT2 = "Hodaya Cohen 323943688";


    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("Usage: java WatermarkApp <directory_path>");
            return;
        }

        File dir = new File(args[0]);
        if (!dir.exists() || !dir.isDirectory()) {
            System.out.println("Invalid directory: " + args[0]);
            return;
        }

        File[] images = dir.listFiles((d, name) -> name.toLowerCase().endsWith(".jpg") || name.toLowerCase().endsWith(".png"));
        if (images == null || images.length == 0) {
            System.out.println("No images found in directory.");
            return;
        }
        File outputDir = new File(args[0] + "/LotemOutput");
        if(!outputDir.exists()){
            outputDir.mkdir();
        }

        for (File image : images) {
            addWatermark(image);
        }

        System.out.println("Watermark added to all images.");
    }

    private static void addWatermark(File imageFile) {
        try {
            BufferedImage image = ImageIO.read(imageFile);
            Graphics2D g2d = (Graphics2D) image.getGraphics();
            g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            g2d.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.5f));
            g2d.setColor(Color.BLACK);
            g2d.setFont(new Font("Arial", Font.BOLD, image.getWidth() / 15));
            int x = image.getWidth() / 10 - 100;
            int y = image.getHeight() - image.getHeight() / 10;
            g2d.drawString(WATERMARK_TEXT1, x, y);
            g2d.drawString(WATERMARK_TEXT2, x, y-=300);

            g2d.dispose();
            ImageIO.write(image, "png", new File(imageFile.getParent() + "/LotemOutput", "watermarked_" + imageFile.getName()));

            System.out.println("Watermark added to: " + imageFile.getName());
        } catch (Exception e) {
            System.err.println("Error processing file: " + imageFile.getName());
            e.printStackTrace();
        }
    }
}
