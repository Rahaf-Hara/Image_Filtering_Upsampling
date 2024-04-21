#include "kernels.cuh"
#include <chrono>
using namespace std::chrono;

int sigma_slider_max = 255;

int range_sigma_slider = 50;

int window_slider_max = 57;

int window_size_slider = 5;

float spatial_sigma = ((float)window_size_slider/2) / 2.5;


cv::Mat low_res, high_res, result_img;

int mode;

void on_trackbar(int, void*)
{
    // Retrieve current trackbar values
    range_sigma_slider = cv::getTrackbarPos("Range Sigma", "Upsampling");
    window_size_slider = cv::getTrackbarPos("Window Size", "Upsampling");

    // Ensure window size is odd
    if(window_size_slider % 2 == 0) {
        window_size_slider++;
    }
    if(window_size_slider <= 1) {
        window_size_slider = 3;
    }

    // Recalculate spatial sigma based on updated window size
    spatial_sigma = ((float)window_size_slider / 2) / 2.5;

    std::cout << "Spatial Sigma: "      << spatial_sigma << std::endl;
    std::cout << "Range Sigma Slider: " << range_sigma_slider   << std::endl;
    std::cout << "Window Size Slider: " << window_size_slider   << std::endl;

    switch (mode) {
    case 0:
        JBU_Filtering(low_res, high_res, result_img, window_size_slider, spatial_sigma, (float)range_sigma_slider);
        break;
    case 1:
        upsample(low_res, high_res, result_img, window_size_slider, spatial_sigma, (float)range_sigma_slider);
        break;

    default:
        break;
    }

    // Display the updated result
    cv::imshow("Upsampling", result_img);
}

int main(int argc, const char **argv)
{
  if (argc < 4)
  {
    std::cout << "Execution Format..."                               << std::endl;
    std::cout << "./upsampling_gui mode low_res_img_path high_res_img_path" << std::endl;
    std::cout << "mode: (0) Joint Bilateral upsampling"              << std::endl;
    std::cout << "      (1) Iterative Upsample"                      << std::endl;

    return 0;
  }

  // upsampling Methods Selection
  mode = std::atoi(argv[1]);

  // Load images
  low_res = cv::imread(argv[2], cv::IMREAD_GRAYSCALE); 
  high_res = cv::imread(argv[3], cv::IMREAD_GRAYSCALE); 

  // Safety Measurements
  if (high_res.size().height*high_res.size().width < low_res.size().height*low_res.size().width) {
    std::cerr << "Please Make Sure to Follow the Following Format"                      << std::endl;
    std::cerr << "The First Image Cannot be Larger in Dimensions than the Second Image" << std::endl;
    std::cout << "./upsampling_gui mode low_res_img_path high_res_img_path"                    << std::endl;
    return EXIT_FAILURE;
  }
  if (!high_res.data) {
    std::cerr << "No high_res data" << std::endl;
    return EXIT_FAILURE;
  }
  if (!low_res.data) {
    std::cerr << "No low_res data" << std::endl;
    return EXIT_FAILURE;
  }

  result_img = cv::Mat::zeros(high_res.size(), cv::IMREAD_GRAYSCALE);
  cv::namedWindow("Upsampling", cv::WINDOW_NORMAL); 
  cv::resizeWindow("Upsampling", 800, 800);
  // Create trackbars
  cv::createTrackbar("Range Sigma", "Upsampling", nullptr, sigma_slider_max, on_trackbar);
  cv::createTrackbar("Window Size", "Upsampling", nullptr, window_slider_max, on_trackbar);

  // Set initial trackbar positions after creating trackbars
  cv::setTrackbarPos("Range Sigma", "Upsampling", range_sigma_slider);
  cv::setTrackbarPos("Window Size", "Upsampling", window_size_slider);

  on_trackbar(range_sigma_slider, 0);
  cv::waitKey(0);

  return 0;
}