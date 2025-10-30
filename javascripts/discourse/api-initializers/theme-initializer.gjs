import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const router = api.container.lookup("service:router");

  const currentUser = api.getCurrentUser();

  console.log({ currentUser });

  const hasTargetTag = () => {
    const routeName = router.currentRouteName ?? "";
    if (!routeName.startsWith("topic")) return false;

    const topicModel = api.container.lookup("controller:topic")?.model;
    if (!topicModel) return false;

    console.log(topicModel.tags);

    for (const keywork of ["jtag", "ufi", "medusa", "f64", "mod-rom", "emmc", "ufs"]) {
      for (const element of topicModel.tags || []) {
        console.log({ element });
        if (element.includes(keywork)) {
          return element;
        }
      }
    }

    return false;
  };

  const hideContent = () => {
    const mainOutlet = document.querySelector("#main");
    if (mainOutlet) mainOutlet.style.display = "none";
    document.body.style.overflow = "hidden";
  };

  const showContent = () => {
    const mainOutlet = document.querySelector("#main");
    if (mainOutlet) mainOutlet.style.display = "";
    document.body.style.overflow = "";
  };

  const showLoginAlert = async () => {
    const result = await Swal.fire({
      title: "Nội dung này chỉ dành cho thành viên",
      text: "Bạn cần đăng nhập để xem bài viết này.",
      icon: "warning",
      width: 800,
      confirmButtonText: "Tiếp tục",
      cancelButtonText: "Quay lại",
      showCancelButton: true,
      reverseButtons: true,
      allowOutsideClick: false,
      allowEscapeKey: false,
      customClass: {
        confirmButton: "btn btn-text btn-primary btn-small sign-up-button",
        cancelButton: "btn btn-text btn-danger btn-small",
      },
    });

    if (result.isConfirmed) {
      window.location.href = "/login";
    }
    //
    else if (result.isDismissed || result.dismiss === Swal.DismissReason.cancel) {
      showContent();
      window.history.back();
    }
  };

  const showNotification = async () => {
    const result = await Swal.fire({
      title: "Tài khoản bị hạn chế",
      text: "Vui lòng liên hệ quản trị viên qua Zalo 0979799247",
      icon: "error",
      width: 800,
      allowOutsideClick: false,
      allowEscapeKey: false,
      confirmButtonText: "Quay lại",
      customClass: {
        confirmButton: "btn btn-text btn-danger btn-small",
      },
      backdrop: `rgba(0,0,0,0.9)`,
    });

    if (result.isConfirmed) {
      window.location.href = "/";
    }
  };

  const processPage = async () => {
    if (!hasTargetTag()) return;

    hideContent();

    if (!currentUser) {
      await showLoginAlert();
      return;
    }

    if (!currentUser.title === "verified") {
      await showNotification();
      return;
    }

    showContent();
  };

  api.onAppEvent("page:loaded", processPage);
  api.onPageChange(processPage);
});
