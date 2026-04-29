resource "local_file" "Cam_file" {
  content  = "Chinese-Food"
  filename = "${path.module}/foo.bar"
}