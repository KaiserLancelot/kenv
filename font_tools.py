from fontTools import subset


def to_subset_woff2(font_file_name, out_file_name, used_words):
    opt = subset.Options()
    font = subset.load_font(font_file_name, opt)

    subsetter = subset.Subsetter()
    subsetter.populate(text=used_words)
    subsetter.subset(font)

    opt.flavor = 'woff2'
    subset.save_font(font, out_file_name, opt)
