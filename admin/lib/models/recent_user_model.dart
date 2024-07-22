class RecentUser {
  final String? icon, name, date, posts, role, email, action;

  RecentUser(
      {this.icon,
      this.name,
      this.date,
      this.posts,
      this.role,
      this.email,
      this.action});
}

List recentUsers = [
  RecentUser(
    icon: "assets/icons/xd_file.svg",
    name: "Deniz Çolak",
    role: "New",
    email: "de***ak@huawei.com",
    date: "01-03-2021",
    posts: "4",
    action: "Post",
  ),
  RecentUser(
    icon: "assets/icons/Figma_file.svg",
    name: "S*** Ç****",
    role: "Creator",
    email: "se****k1@google.com",
    date: "27-02-2021",
    posts: "19",
    action: "Teel",
  ),
  RecentUser(
    icon: "assets/icons/doc_file.svg",
    name: "N***** D****",
    role: "Verified",
    email: "ne****tr@google.com",
    date: "23-02-2021",
    posts: "32",
    action: "Live",
  ),
  RecentUser(
    icon: "assets/icons/sound_file.svg",
    name: "B***** K****",
    role: "Trending",
    email: "bu****lk@google.com",
    date: "21-02-2021",
    posts: "3",
    action: "Teel",
  ),
  RecentUser(
    icon: "assets/icons/media_file.svg",
    name: "A**** S**** K****",
    role: "Trending",
    email: "ah****az@google.com",
    date: "23-02-2021",
    posts: "2",
    action: "Live",
  ),
  RecentUser(
    icon: "assets/icons/pdf_file.svg",
    name: "T***** S****",
    role: "New",
    email: "te****cu@google.com",
    date: "25-02-2021",
    posts: "3",
    action: "Post",
  ),
  RecentUser(
    icon: "assets/icons/excle_file.svg",
    name: "K***** D****",
    role: "Creator",
    email: "ke****an@gmail.com",
    date: "25-02-2021",
    posts: "34",
    action: "XOXO",
  ),
];
